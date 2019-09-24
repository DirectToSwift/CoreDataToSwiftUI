//
//  D2SFault.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol Swift.Identifiable

public protocol D2SFaultResolver: AnyObject {
  
  func resolveFaultWithID(_ id: NSManagedObjectID)
}

public enum D2SFault<Object /*: AnyObject*/, Resolver>
              where Resolver: D2SFaultResolver
{
  // In the CoreData context we still need faults. They represent objects
  // for which we don't even know the object id.
  // Note: Using AnyObject in the generic here breaks everything!
  
  /// Keep an object reference as unowned, to break cycles
  public struct Unowned<Object: AnyObject> {
    unowned let object: Object
  }
  
  init(_ id: NSManagedObjectID, _ resolver: Resolver) {
    self = .fault(id, Unowned(object: resolver))
  }
  init(index: Int, resolver: Resolver) {
    self.init(IndexGlobalID.make(index), resolver)
  }

  case object(NSManagedObjectID, Object)
  case fault(NSManagedObjectID, Unowned<Resolver>)
  
  public func accessingFault() -> Bool {
    switch self {
      case .object: return false
      case .fault(let id, let resolver):
        resolver.object.resolveFaultWithID(id)
        return true
    }
  }
  
  public var isFault: Bool {
    switch self {
      case .object: return false
      case .fault:  return true
    }
  }
  
  public var object : Object {
    switch self {
      case .object(_, let object): return object
      case .fault:
        fatalError("attempt to access fault as resolved object \(self)")
    }
  }

  /**
   * Returns nil if it is still a fault, but triggers a fetch.
   */
  public subscript<V>(dynamicMember keyPath:
                        ReferenceWritableKeyPath<Object, V>)
         -> V?
  {
    guard !accessingFault() else { return nil }
    return object[keyPath: keyPath]
  }
}

extension D2SFault: Equatable {
  public static func == (lhs: D2SFault, rhs: D2SFault) -> Bool {
    switch ( lhs, rhs ) {
      case ( .fault(let lhs, _), .fault(let rhs, _) ):
        return lhs == rhs
      case ( .object(_, let lhs), .object(_, let rhs) ):
        // Yeah, because putting the AnyObject into the generic signature
        // mysteriously breaks everything.
        return (lhs as AnyObject) === (rhs as AnyObject)
      default:
        return false
    }
  }
}
extension D2SFault: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}

extension D2SFault: Identifiable {

  // TODO: This is still pending. It now works because we replace the index GIDs
  //       w/ real GIDs. But as soon as we can fault a real GID, it _might_
  //       fail again.
  
  // I think this might not work because SwiftUI doesn't notice changes to the
  // fault state? Even though the enum _does_ change.
  public var id: NSManagedObjectID {
    switch self {
      case .object(let id, _): return id
      case .fault (let id, _): return id
    }
  }
}
