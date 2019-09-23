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
    try managedObjectContext.count(for: fr)
  }
  public func _primaryFetchGlobalIDs(_ fr: NSFetchRequest<NSManagedObjectID>)
              throws -> [ NSManagedObjectID ]
  {
    if fr.resultType != .managedObjectIDResultType {
      let fs = fr.objectIDsCopy()
      fs.resultType = .managedObjectIDResultType
      return try managedObjectContext.fetch(fs)
    }
    else {
      return try managedObjectContext.fetch(fr)
    }
  }
  
  public func fetchGlobalIDs() throws -> [ NSManagedObjectID ] {
    let fs = fetchRequest?.objectIDsCopy()
          ?? NSFetchRequest<NSManagedObjectID>(entityName: entity.name ?? "")
    fs.resultType = .managedObjectIDResultType
    return try _primaryFetchGlobalIDs(fs)
  }
  public func fetchGlobalIDs(_ fs: NSFetchRequest<Object>)
              throws -> [ NSManagedObjectID ]
  {
    let fs = fs.objectIDsCopy()
    fs.resultType = .managedObjectIDResultType
    return try _primaryFetchGlobalIDs(fs)
  }
}

public extension ManagedObjectDataSource {
  
  func find() throws -> Object? {
    let fs = try fetchRequestForFetch()
    fs.fetchLimit = 2
    
    let objects = try _primaryFetchObjects(fs)
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
