//
//  D2SToOneFetch.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI

/**
 * This is used to fetch the toOne relship of an object.
 */
public final class D2SToOneFetch: ObservableObject {
  
  @Published var destination : NSManagedObject?
  
  let object      : OActiveRecord
  let propertyKey : String
  
  var isReady : Bool { destination != nil }
  
  public init(object: NSManagedObject, propertyKey: String) {
    self.object      = object
    self.propertyKey = propertyKey
    
    func lookup(_ kp: String, in object: NSManagedObject) -> NSManagedObject? {
      KeyValueCoding.value(forKeyPath: kp, inObject: object)
        as? OActiveRecord
    }
    
    self.destination = lookup(propertyKey, in: object)
  }
  
  func resume() {
    guard destination == nil else { return }
    
    // Note: This _does_ try to fetch `nil` values, which is not strictly
    //       wrong.
    
    _ = object.fetchToOneRelationship(propertyKey)
      .receive(on: RunLoop.main) // this keeps it around
      .catch { ( error : Swift.Error ) -> Just<NSManagedObject?> in
        return Just(nil)
      }
      .sink { newValue in
        // Update the AR. This is a little meh, but avoids continuous fetches.
        self.object.setValue(newValue, forKeyPath: self.propertyKey)
        self.destination = newValue
      }
  }
}
