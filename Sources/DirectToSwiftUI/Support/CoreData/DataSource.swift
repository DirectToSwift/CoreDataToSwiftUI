//
//  DataSource.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 23.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public protocol DataSource {
  
  associatedtype Object : NSManagedObject

  var fetchRequest : NSFetchRequest<Object>? { set get }

  func fetchObjects()   throws -> [ Object ]
  func fetchCount()     throws -> Int
  func fetchGlobalIDs() throws -> [ NSManagedObjectID ]
  
  func fetchRequestForFetch() throws -> NSFetchRequest<Object>

  func _primaryFetchObjects  (_ fr: NSFetchRequest<Object>) throws -> [ Object ]
  func _primaryFetchCount    (_ fr: NSFetchRequest<Object>) throws -> Int
  func _primaryFetchGlobalIDs(_ fr: NSFetchRequest<NSManagedObjectID>) throws
       -> [ NSManagedObjectID ]
}

public extension DataSource {

  func fetchObjects(_ fr: NSFetchRequest<Object>) throws -> [ Object ] {
    try _primaryFetchObjects(fr)
  }

  func fetchObjects() throws -> [ Object ] {
    try _primaryFetchObjects(try fetchRequestForFetch())
  }
  func fetchCount() throws -> Int {
    try _primaryFetchCount(try fetchRequestForFetch())
  }
}

public class ManagedObjectDataSource<Object: NSManagedObject>: DataSource {
  
  public let managedObjectContext  : NSManagedObjectContext
  public let entity                : NSEntityDescription
  public var fetchRequest          : NSFetchRequest<Object>?
  
  public init(managedObjectContext : NSManagedObjectContext,
              entity               : NSEntityDescription)
  {
    self.managedObjectContext = managedObjectContext
    self.entity               = entity
  }
  
  public func fetchRequestForFetch() throws -> NSFetchRequest<Object> {
    if let c = fetchRequest?.typedCopy() { return c }
    return NSFetchRequest<Object>(entityName: entity.name ?? "")
  }

  public func _primaryFetchObjects(_ fr: NSFetchRequest<Object>) throws
              -> [ Object ]
  {
    try managedObjectContext.fetch(fr)
  }
  public func _primaryFetchCount(_ fr: NSFetchRequest<Object>) throws -> Int {
    if fr.resultType != .countResultType {
      let fr = fr.countCopy()
      fr.resultType = .countResultType
      return try managedObjectContext.count(for: fr)
    }
    else {
      return try managedObjectContext.count(for: fr)
    }
  }
  public func _primaryFetchGlobalIDs(_ fr: NSFetchRequest<NSManagedObjectID>)
              throws -> [ NSManagedObjectID ]
  {
    if fr.resultType != .managedObjectIDResultType {
      let fr = fr.objectIDsCopy()
      fr.resultType = .managedObjectIDResultType
      return try managedObjectContext.fetch(fr)
    }
    else {
      return try managedObjectContext.fetch(fr)
    }
  }
  
  public func fetchGlobalIDs() throws -> [ NSManagedObjectID ] {
    let fr = fetchRequest?.objectIDsCopy()
          ?? NSFetchRequest<NSManagedObjectID>(entityName: entity.name ?? "")
    fr.resultType = .managedObjectIDResultType
    return try _primaryFetchGlobalIDs(fr)
  }
  public func fetchGlobalIDs(_ fr: NSFetchRequest<Object>)
              throws -> [ NSManagedObjectID ]
  {
    let fr = fr.objectIDsCopy()
    fr.resultType = .managedObjectIDResultType
    return try _primaryFetchGlobalIDs(fr)
  }

  public func fetchCount(_ fr: NSFetchRequest<Object>) throws -> Int {
    return try _primaryFetchCount(fr)
  }

  public func createObject() -> Object {
    NSEntityDescription.insertNewObject(
      forEntityName: entity.name ?? "",
      into: managedObjectContext
    ) as! Object
  }
}

public extension ManagedObjectDataSource {
  
  func find() throws -> Object? {
    let fr = try fetchRequestForFetch()
    fr.fetchLimit = 2
    
    let objects = try _primaryFetchObjects(fr)
    assert(objects.count < 2)
    return objects.first
  }

}

public extension NSManagedObjectContext {
  
  func dataSource<Object: NSManagedObject>(for entity: NSEntityDescription)
       -> ManagedObjectDataSource<Object>
  {
    ManagedObjectDataSource(managedObjectContext: self, entity: entity)
  }
  
}
