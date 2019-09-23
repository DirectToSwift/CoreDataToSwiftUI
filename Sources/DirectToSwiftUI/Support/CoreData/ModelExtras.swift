//
//  ModelExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSManagedObjectModel {
  
  /**
   * Try to find an entity which might form a user database (one which can be
   * queried using login/password)
   */
  func lookupUserDatabaseEntity() -> NSEntityDescription? {
    var lcNameToUserEntity = [ String : NSEntityDescription ]()
    for entity in entities {
      guard let _ = entity.lookupUserDatabaseProperties() else { continue }
      guard let name = entity.name else { continue }
      lcNameToUserEntity[name.lowercased()] = entity
    }
    if lcNameToUserEntity.isEmpty    { return nil }
    if lcNameToUserEntity.count == 1 { return lcNameToUserEntity.values.first }
    
    globalD2SLogger.log("multiple entities have passwords:",
                        lcNameToUserEntity.keys.joined(separator: ","))
    return lcNameToUserEntity["staff"]
        ?? lcNameToUserEntity["userdb"]
        ?? lcNameToUserEntity["accounts"]
        ?? lcNameToUserEntity["account"]
        ?? lcNameToUserEntity["person"]
        ?? lcNameToUserEntity.values.first // any, good luck
  }
}

public extension NSManagedObjectModel {
  
  subscript(entity name: String) -> NSEntityDescription? {
    entitiesByName[name]
  }
}
