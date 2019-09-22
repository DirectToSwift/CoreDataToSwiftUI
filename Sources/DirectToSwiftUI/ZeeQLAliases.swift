//
//  ZeeQLAliases.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 22.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

// Aliases to get going. Should we replace them in the source? TBD
// If we keep them, it'll be a little easier to sync up w/ D2S.

public typealias Model         = NSManagedObjectModel
public typealias Entity        = NSEntityDescription
public typealias Attribute     = NSAttributeDescription
public typealias Relationship  = NSRelationshipDescription

// FIX THIS, those should really get replaced
public typealias OActiveRecord = NSManagedObject
public typealias GlobalID      = NSManagedObjectID
