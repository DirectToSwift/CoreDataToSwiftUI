//
//  DetailDataSource.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {
  
  func qualifierInDestinationForSource(_ source: NSManagedObject)
       -> NSPredicate?
  {
    guard let inverse = inverseRelationship else {
      globalD2SLogger.error("relationship misses inverse:", self)
      return nil
    }
    
    return NSComparisonPredicate(
      leftExpression  : NSExpression(forKeyPath: inverse.name),
      rightExpression : NSExpression(forConstantValue: source),
      modifier: .direct, type: .equalTo, options: []
    )
  }
}


extension NSManagedObject {
  
  func wire(destination: NSManagedObject?,
            to relationship: NSRelationshipDescription)
  {
    self.setValue(destination, forKey: relationship.name)
  }
}

/**
 * This is similar to a GlobalID, but it can match any properties in the
 * destination.
 */
struct JoinTargetID: Hashable {
  // TBD: calc hash once

  let values : [ Any? ]

  init?(source: NSManagedObject, relationship: NSRelationshipDescription) {
    // TBD: if the source has the relationship _object_ assigned,
    //      rather grab the values of the dest object? (and maybe
    //      match them up and report inconsistencies).
    #if true
      globalD2SLogger.error("ERROR: implement:", #function)
      return nil
    #else
    if relationship.joins.isEmpty { return nil }
    
    var hadNonNil = false
    var values = [ Any? ]()
    values.reserveCapacity(relationship.joins.count)
    for join in relationship.joins {
      guard let name  = (join.source?.name ?? join.sourceName),
            let value = source.value(forKey: name) else {
        values.append(nil)
              continue
      }
      values.append(value)
      if !hadNonNil { hadNonNil = true }
    }
    if !hadNonNil { return nil }
    self.values = values
    #endif
  }
  init(destination: NSManagedObject, relationship: NSRelationshipDescription) {
    #if true
      globalD2SLogger.error("ERROR: implement:", #function)
      values = []
    #else
    values = relationship.joins.map { join in
      (join.destination?.name ?? join.destinationName)
        .flatMap { name in destination.value(forKey: name) }
    }
    #endif
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.values.count == rhs.values.count else { return false }
    for i in lhs.values.indices {
      // Yes, I know.
      if !eq(lhs.values[i], rhs.values[i]) { return false }
    }
    return true
  }
  
  func hash(into hasher: inout Hasher) { // lame
    guard let f = values.first else { return }
    if let i = f as? Int    { return i.hash(into: &hasher) }
    if let i = f as? Int64  { return i.hash(into: &hasher) }
    if let i = f as? String { return i.hash(into: &hasher) }
    return String(describing: f).hash(into: &hasher)
  }
  
}
