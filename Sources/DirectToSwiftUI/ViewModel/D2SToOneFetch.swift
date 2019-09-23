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
  
  let object      : NSManagedObject
  let propertyKey : String
  
  var isReady : Bool { destination != nil }
  
  public init(object: NSManagedObject, propertyKey: String) {
    self.object      = object
    self.propertyKey = propertyKey
    self.destination = object.value(forKeyPath: propertyKey) as? NSManagedObject
  }
  
  func resume() {
  }
}
