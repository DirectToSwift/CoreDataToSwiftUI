//
//  FetchRequestExtras.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 23.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSFetchRequest {
  
  @objc convenience init(entity: NSEntityDescription) {
    assert(entity.name != nil)
    self.init(entityName: entity.name ?? "")
  }

  @objc func typedCopy() -> NSFetchRequest<ResultType> {
    let me = copy()
    guard let typed = me as? NSFetchRequest<ResultType> else {
      fatalError("fetch request lost its type! \(type(of: me))")
    }
    return typed
  }

  @objc func objectIDsCopy() -> NSFetchRequest<NSManagedObjectID> {
    let me = copy()
    guard let typed = me as? NSFetchRequest<NSManagedObjectID> else {
      fatalError("can't convert fetch request type! \(type(of: me))")
    }
    return typed
  }
  @objc func countCopy() -> NSFetchRequest<NSNumber> {
    let me = copy()
    guard let typed = me as? NSFetchRequest<NSNumber> else {
      fatalError("can't convert fetch request type! \(type(of: me))")
    }
    return typed
  }
}

public extension NSFetchRequest {

  @objc func limit(_ limit: Int) -> NSFetchRequest<ResultType> {
    let fr = typedCopy()
    fr.fetchLimit = limit
    return fr
  }
  @objc func offset(_ offset: Int) -> NSFetchRequest<ResultType> {
    let fr = typedCopy()
    fr.fetchOffset = offset
    return fr
  }

  @objc func `where`(_ predicate: NSPredicate) -> NSFetchRequest<ResultType> {
    let fr = typedCopy()
    fr.predicate = predicate
    return fr
  }

  #if false // doesn't fly, needs @objc which doesn't work w/ Range
  func range(_ range: Range<Int>) -> NSFetchRequest<ResultType> {
    let fr = typedCopy()
    fr.fetchOffset = range.lowerBound
    fr.fetchLimit  = range.count
    return fr
  }
  #endif

}
