//
//  DetailDataSource.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

extension NSRelationshipDescription {
  
  func predicateInDestinationForSource(_ source: NSManagedObject)
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
