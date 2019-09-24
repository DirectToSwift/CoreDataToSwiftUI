//
//  D2SDisplayGroup.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI
import CoreData

/**
 * Simple notification delegate.
 */
public protocol D2SObjectContainer {
  
}

/**
 * This handles the fetches and results for a single fetch specification.
 *
 * Properties:
 * - error
 * - results (a collection of D2SFault values)
 * - queryString (search for a string, via `predicateForQueryString`)
 * - sortAttribute
 */
public final class D2SDisplayGroup<Object: NSManagedObject>
                   : ObservableObject, D2SFaultResolver, D2SObjectContainer
{
  
  @Published var error   : Swift.Error?
  @Published var results = SparseFaultArray<Object, D2SDisplayGroup<Object>>()
  
  @Published var queryString = "" {
    didSet {
      guard oldValue != queryString else { return }
      let qs = dataSource.entity.predicateForQueryString(queryString)
      let q  = and(qs, auxiliaryPredicate)
      guard !q.isEqual(to: fetchRequest.predicate) else { return }
      fetchRequest.predicate = q
    }
  }
  @Published var sortAttribute : NSAttributeDescription? = nil {
    didSet {
      guard oldValue !== sortAttribute else { return }
      if let newValue = sortAttribute {
        self.fetchRequest.sortDescriptors = [
          NSSortDescriptor(key: newValue.name, ascending: true)
        ]
      }
      else {
        self.fetchRequest.sortDescriptors =
          dataSource.entity.d2s.defaultSortDescriptors
      }
    }
  }
  
  internal let dataSource         : ManagedObjectDataSource<Object>
  private  let batchCount         : Int
  
  private  var auxiliaryPredicate : NSPredicate? = nil
  private  var fetchRequest       : NSFetchRequest<Object> {
    didSet { setNeedsRefetch() }
  }
  
  private func setNeedsRefetch() { needsRefetch.send(fetchRequest) }
  private var needsRefetch = PassthroughSubject<NSFetchRequest<Object>, Never>()
    // Not using @Published because we want a _didset_
  
  public init(dataSource          : ManagedObjectDataSource<Object>,
              auxiliaryPredicate  : NSPredicate? = nil,
              displayPropertyKeys : [ String ]?  = nil,
              batchCount          : Int          = 20)
  {
    // Note: We always fetch full objects, for the list we could also just
    //       select the displayPropertyKeys, but then we'd have to fetch the
    //       full object for editing. Which might make sense :-)
    self.batchCount         = batchCount
    self.dataSource         = dataSource
    self.auxiliaryPredicate = auxiliaryPredicate
    self.fetchRequest =
      buildInitialFetchSpec(for: dataSource,
                            auxiliaryPredicate: auxiliaryPredicate)
    let entity = dataSource.entity
    if let keys = displayPropertyKeys {
      self.fetchRequest.relationshipKeyPathsForPrefetching =
        entity.prefetchPathesForPropertyKeys(keys)
    }
    
    results.assignResolver(self)
    
    _ = needsRefetch
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .sink { [weak self] newValue in
        self?.fetchCount(newValue)
      }
    
    self.fetchCount(fetchRequest)
  }
  
  
  // MARK: - Reloading
  
  public func reload() {
    // TBD: somehow cancel running fetches
    results.reset()
    self.fetchCount(fetchRequest)
  }
  
  
  // MARK: - Errors
  
  private func handleError(_ error: Swift.Error) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    self.error = error
  }
  
  
  // MARK: - Fetching Counts
  
  private func integrateCount(_ count: Int) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    #if false // nope, a fetch count means we rebuild!
      if count == results.count { return } // all good already
    #endif
    globalD2SLogger.info("refresh with count:", count)
    
    // TBD: we could decide to fetch all pkeys based on the count?
    //      well, this affects the type. Only if the single primary key
    //      is an Int (because then it would be compatible with the Index)?
    
    // When the count changes, it always implies that the whole set has changed!
    // E.g. an element in between could have changed!
    // (this is why paging by index is quite generally not a great idea :-) )
    // Note: We keep the fetched GIDs!
    // FIXME: decouple this.
    results.clearOrderAndApplyNewCount(count)
  }
  
  private func fetchCount(_ fetchRequest: NSFetchRequest<Object>) {
    // TODO: make async like in ZeeQL version
    do {
      let count = try dataSource.fetchCount()
      integrateCount(count)
    }
    catch {
      handleError(error)
    }
  }
  
  
  // MARK: - Fetching Values
  
  // TBD: rewrite this using Combine :-)
  
  private func integrateResults(_ results: [ Object ], for range: Range<Int>) {
    // TBD: Avoid continuous change notifications by not doing in place
    //      array modifications. Contra: copies each time.
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    // FIXME: if we get less, show an error!
    if results.count != range.count {
      // TODO:
      // There have been less than we thought. We need to refetch everything
      // as something affected the count.
      globalD2SLogger.error("count mismatch, expected:", range.count,
                            "returned:", results.count)
      assert(results.count <= range.count,
             "count mismatch, concurrent edit (valid but not implemented :-))")
    }
    
    var newResults = self.results
    for ( i, result ) in results.enumerated() {
      let targetIndex = i + range.lowerBound
      assert(newResults.count > targetIndex)
      
      let gid = result.objectID
      
      if newResults.count > targetIndex {
        newResults[targetIndex] = .object(gid, result)
      }
      else {
        newResults.append(.object(gid, result))
      }
    }
    
    self.results = newResults
  }
  
  private func fetchRangeForIndex(_ index: Int) -> Range<Int> {
    let batchIndex      = index / batchCount
    let batchStartIndex = batchIndex * batchCount
    
    let endIndex = results.index(batchStartIndex, offsetBy: batchCount,
                                 limitedBy: results.endIndex)
                ?? results.endIndex
    
    return batchStartIndex..<endIndex
  }
  
  public func resolveFaultWithID(_ gid: NSManagedObjectID) {
    // Yeah, we are just prepping things for the real imp using regular GIDs
    if let indexGID = gid as? IndexGlobalID {
      return resolveFault(at: indexGID.index)
    }
    
    globalD2SLogger.error("TODO: resolve fault w/ GID:", gid)
  }
  
  public func resolveFault(at index: Int) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    guard case .fault = results[index] else { return } // already fetched
    
    let fetchRange = fetchRangeForIndex(index)
    
    #if false // This raises (init via name, not used w/ MOC yet)
      let entity = fetchRequest.entity ?? dataSource.entity
    #else
      let entity = dataSource.entity
    #endif
    let fs     = fetchRequest.offset(fetchRange.lowerBound)
                                   .limit (fetchRange.count)
    assert(fs.sortDescriptors != nil && !(fs.sortDescriptors?.isEmpty ?? true))
    
    // FIXME: Make this async like in the ZeeQL D2S. Needs a context
    do {
      let globalIDs = try dataSource.fetchGlobalIDs(fs)
      
      var missingGIDs = Set<NSManagedObjectID>()
      var gidToObject = [ NSManagedObjectID : Object ]()
      for gid in globalIDs {
        if let object = self.results[gid] { gidToObject[gid] = object }
        else { missingGIDs.insert(gid) }
      }
      
      if missingGIDs.isEmpty {
        let objects = globalIDs.compactMap { gidToObject[$0] }
        self.integrateResults(objects, for: fetchRange)
        return
      }
      
      let objectFS = self.fetchRequest.typedCopy()
      objectFS.predicate = entity.predicateForGlobalIDs(missingGIDs)
      let fetchedObjects = try dataSource.fetchObjects(objectFS)
      
      for object in fetchedObjects {
        gidToObject[object.objectID] = object
      }

      let objects = globalIDs.compactMap { gidToObject[$0] }
      self.integrateResults(objects, for: fetchRange)
    }
    catch {
      return self.handleError(error)
    }
  }
}

internal let D2SFetchQueue = DispatchQueue(label: "de.zeezide.d2s.fetchqueue")

fileprivate func buildInitialFetchSpec<Object: NSManagedObject>
                   (for     dataSource : ManagedObjectDataSource<Object>,
                    auxiliaryPredicate : NSPredicate?)
                 -> NSFetchRequest<Object>
{
  // all cases, kinda non-sense here
  var fs : NSFetchRequest<Object> = {
    if let fs = dataSource.fetchRequest?.typedCopy() { return fs }
    return NSFetchRequest<Object>(entityName: dataSource.entity.name ?? "")
  }()
  
  // We NEED a sort ordering (unless we prefetch all IDs)
  if (fs.sortDescriptors?.count ?? 0) == 0 {
    fs.sortDescriptors = dataSource.entity.d2s.defaultSortDescriptors
  }
  #if os(macOS)
    if !(fs.sortDescriptors != nil && !(fs.sortDescriptors?.isEmpty ?? true)) {
      globalD2SLogger.error("got no sort orderings for fetchspec:", fs)
    }
  #else
    assert(fs.sortDescriptors != nil && !(fs.sortDescriptors?.isEmpty ?? true))
  #endif
  
  if let aux = auxiliaryPredicate {
    fs.predicate = aux.and(fs.predicate)
  }
  
  return fs
}
