//
//  D2SEntity.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSEntityDescription {
  
  var attributes : Dictionary<String, NSAttributeDescription>.Values {
    attributesByName.values
  }
  var relationships : Dictionary<String, NSRelationshipDescription>.Values {
    relationshipsByName.values
  }

}

public extension NSEntityDescription {
  var d2s : EntityD2S { return EntityD2S(entity: self) }
}

public struct EntityD2S {
  let entity : NSEntityDescription
}

public extension EntityD2S {
  
  var isDefault    : Bool { entity is D2SDefaultEntity }

  var defaultTitle : String { return entity.name ?? "" }

  var defaultSortDescriptors : [ NSSortDescriptor ] {
    // This is not great, but there is no reasonable option?
    guard let firstAttribute = entity.attributes.first else { return [] }
    return [ NSSortDescriptor(key: firstAttribute.name, ascending: true) ]
  }
  
  /**
   * This first looks at the `classPropertyNames`. If set, it filters out the
   * INT foreign keys and returns them.
   *
   * If `classPropertyNames` is not set, returns attributes + relationships,
   * while also filterting the attributes for INT foreign keys.
   */
  var defaultAttributeAndRelationshipPropertyKeys : [ String ] {
    // Note: It is a speciality of AR that we keep the IDs as class properties.
    //       That would not be the case for real, managed, EOs.
    // Here we want to keep the primary key for display, but drop all the
    // keys of the relationships.
    return entity.properties.map { $0.name }
  }
  
  var defaultAttributeAndToOnePropertyKeys : [ String ] {
    var propertyKeys = entity.attributes.map { $0.name }
    
    for rs in entity.relationshipsByName.values {
      if !rs.isToMany {
        propertyKeys.append(rs.name)
      }
    }
    
    return propertyKeys
  }

  var defaultDisplayPropertyKeys : [ String ] {
    // Note: We do not sort but assume proper ordering
    return entity.attributes.map { $0.name }
  }
  
  var defaultSortPropertyKeys : [ String ] {
    return entity.attributes.map { $0.name }
  }
}
