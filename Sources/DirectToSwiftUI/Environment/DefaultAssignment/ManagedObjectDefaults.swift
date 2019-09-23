//
//  ManagedObjectExtras.swift
//  Direct to SwiftUI (Mobile)
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSManagedObject {
  
  var d2s : D2S { return D2S(object: self) }
  
  struct D2S {
    
    let object : NSManagedObject
    
    public var isDefault : Bool {
      return object === D2SKeys.object.defaultValue
    }
    
    public var defaultTitle : String {
      return Self.title(for: object)
    }
    
    
    // MARK: - Title
    
    static func title(for object: NSManagedObject) -> String {
      return title(for: object, entity: object.entity)
    }
    
    static func title(for object: NSManagedObject, entity: Entity) -> String {
      // Look for string attributes, prefer 'title' exact match
      var firstString   : Attribute?
      var containsTitle : Attribute?
      
      func string(for attribute: Attribute?) -> String? {
        guard let attribute = attribute else { return nil }
        guard let value = object.value(forKey: attribute.name) else { return nil }
        guard let s = value as? String else { return nil }
        guard !s.isEmpty else { return nil }
        return s
      }
      
      for attribute in entity.attributes {
        guard attribute.isStringAttribute else { continue }
        let lowname = attribute.name.lowercased()
        if lowname == "title" {
          if let s = string(for: attribute) { return s }
        }
        else if containsTitle == nil, lowname.contains("title") {
          containsTitle = attribute
        }
        else if firstString == nil {
          firstString = attribute
        }
      }
      
      if let s = string(for: containsTitle) { return s }
      if let s = string(for: firstString)   { return s } // TBD

      // TBD
      let s = object.objectID.uriRepresentation().lastPathComponent
      if !s.isEmpty { return s }
      
      return String("\(object.objectID)")
    }
  }
  
}
