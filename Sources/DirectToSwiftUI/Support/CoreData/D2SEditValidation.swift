//
//  D2SEditValidation.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public protocol D2SAttributeValidator {
  
  associatedtype Object : NSManagedObject
  
  var attribute : NSAttributeDescription { get }
  var object    : Object                 { get }
 
  var isValid   : Bool                   { get }
}

public extension D2SAttributeValidator {

  var isValid : Bool {
    return object.isNew
      ? attribute.validateForInsert(object)
      : attribute.validateForUpdate(object)
  }
}


public protocol D2SRelationshipValidator {
  
  associatedtype Object : NSManagedObject
  
  var relationship : NSRelationshipDescription { get }
  var object       : Object                    { get }
 
  var isValid      : Bool                      { get }
}

public extension D2SRelationshipValidator {

  var isValid : Bool {
    return object.isNew
      ? relationship.validateForInsert(object)
      : relationship.validateForUpdate(object)
  }
}
