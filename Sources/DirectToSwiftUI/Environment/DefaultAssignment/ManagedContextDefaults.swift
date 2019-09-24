//
//  D2SDatabase.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
  
  var d2s : D2S { return D2S(moc: self) }
  
  struct D2S {
    let moc: NSManagedObjectContext

    public var isDefault : Bool { moc === D2SKeys.ruleObjectContext.defaultValue }
    
    public var hasDefaultTitle: Bool {
      guard let psc = moc.persistentStoreCoordinator else { return false }
      return (psc.persistentStores.first?.url != nil) || psc.name != nil
    }

    public var defaultTitle : String {
      if let psc = moc.persistentStoreCoordinator {
        if let p = psc.persistentStores.first?.url?.deletingPathExtension()
                                                   .lastPathComponent,
           !p.isEmpty
        {
          return p
        }
        if let n = psc.name, !n.isEmpty { return n }
      }

      return "CoreData" // /shrug
    }
  }
}
