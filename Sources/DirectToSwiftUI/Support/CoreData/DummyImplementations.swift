//
//  DummyImplementations.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

// Those are here to workaround the issue that we don't want any
// optionals in Views. Which may or may not be a good decision.

internal final class D2SDummyObjectContext: NSManagedObjectContext {
  static let shared : NSManagedObjectContext = D2SDummyObjectContext()
  init() {
    super.init(concurrencyType: .mainQueueConcurrencyType)
    let psc = NSPersistentStoreCoordinator(
                managedObjectModel: D2SDefaultModel.shared)
    persistentStoreCoordinator = psc
  }
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }
}

internal final class D2SDefaultModel: NSManagedObjectModel {
  static let shared : NSManagedObjectModel = D2SDefaultModel()
  override init() {
    super.init()
  }
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }
  
  override var entities: [NSEntityDescription] {
    set {
      fatalError("unexpected call to set `entities`")
    }
    get { [ D2SDefaultEntity.shared ] }
  }
  override var entitiesByName: [String : NSEntityDescription] {
    [ "_dummy": D2SDefaultEntity.shared ]
  }
}

internal final class D2SDefaultEntity: NSEntityDescription {
  static let shared = D2SDefaultEntity()
  override init() {
    super.init()
    name = "_dummy"
    managedObjectClassName = NSStringFromClass(D2SDefaultObject.self)
  }
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }
  override var managedObjectModel: NSManagedObjectModel {
    return D2SDefaultModel.shared
  }
}
internal final class D2SDefaultAttribute: NSAttributeDescription {}

internal final class D2SDefaultRelationship: NSRelationshipDescription {}

internal final class D2SDefaultObject: NSManagedObject {
  init() {
    // fails in class for entity
    super.init(entity     : D2SDefaultEntity     .shared,
               insertInto : D2SDummyObjectContext.shared)
  }
}
