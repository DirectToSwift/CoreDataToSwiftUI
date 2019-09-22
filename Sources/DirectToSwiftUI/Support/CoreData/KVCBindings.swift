//
//  KVCBindings.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import CoreData

public extension KeyValueCodingType where Self : MutableKeyValueCodingType {
  
  func binding(_ key: String) -> Binding<Any?> {
    return KeyValueCoding.binding(key, for: self)
  }
}

public extension KeyValueCoding { // bindings for KVC keys
  
  static func binding(_ key: String, for object: Any?) -> Binding<Any?> {
    if let object = object {
      return Binding<Any?>(get: {
        KeyValueCoding.value(forKey: key, inObject: object)
      }) {
        newValue in
        KeyValueCoding.setValue(newValue, forKey: key, inObject: object)
      }
    }
    else {
      return Binding<Any?>(get: { return nil }) { newValue in
        globalD2SLogger.error("attempt to write to nil binding:", key)
        assertionFailure("attempt to write to nil binding: \(key)")
      }
    }
  }
  
  static func binding(_ key: String, for object: KeyValueCodingType)
              -> Binding<Any?>
  {
    return Binding<Any?>(get: { object.value(forKey: key) },
                         set: { object.setValue($0, forKey: key) })
  }
}
