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
  
  func fetchObjects() throws -> [ Object ]
  func fetchCount()   throws -> Int

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
  
  public func fetchObjects() throws -> [ Object ] {
    try managedObjectContext.fetch(try fetchRequestForFetch())
  }
  public func fetchCount() throws -> Int {
    try managedObjectContext.count(for: try fetchRequestForFetch())
  }

  public func fetchRequestForFetch() throws -> NSFetchRequest<Object> {
    fetchRequest?.typedCopy()
      ?? NSFetchRequest<Object>(entityName: entity.name ?? "")
  }
}

public extension NSManagedObjectContext {
  
  func dataSource<Object: NSManagedObject>(for entity: NSEntityDescription)
       -> ManagedObjectDataSource<Object>
  {
    ManagedObjectDataSource(managedObjectContext: self, entity: entity)
  }
  
}
