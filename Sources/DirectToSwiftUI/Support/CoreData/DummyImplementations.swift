//
//  DummyImplementations.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

// Those are here to workaround the issue that we don't want any
// optionals in Views. Which may or may not be a good decision.

internal final class D2SDummyObjectContext: NSManagedObjectContext {}

internal final class D2SDefaultModel: NSManagedObjectModel {}

internal final class D2SDefaultEntity: NSEntityDescription {
  static let shared = D2SDefaultEntity()
}
internal final class D2SDefaultAttribute: NSAttributeDescription {}

internal final class D2SDefaultRelationship: NSRelationshipDescription {}
