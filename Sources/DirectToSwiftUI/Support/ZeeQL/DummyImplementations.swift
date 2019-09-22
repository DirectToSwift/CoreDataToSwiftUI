//
//  DummyImplementations.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

// Those are here to workaround the issue that we don't want any
// optionals in Views. Which may or may not be a good decision.

internal final class D2SDummyObjectContext: NSManagedObjectContext {
}

internal final class D2SDefaultModel: Model {
  init() {
    super.init(entities: [])
  }
}

internal final class D2SDefaultEntity: NSEntityDescription {
  static let shared = D2SDefaultEntity()
  var name          : String           { ""    }
  var isPattern     : Bool             { false }
  var attributes    : [ Attribute    ] { []    }
  var relationships : [ Relationship ] { []    }
}

internal final class D2SDefaultAttribute: NSAttributeDescription {
  var name: String { "" }
}

internal final class D2SDefaultRelationship: NSRelationshipDescription {
  var name              : String   { ""    }
  var entity            : Entity   { D2SDefaultEntity.shared }
  var destinationEntity : Entity?  { nil   }
  var isToMany          : Bool     { false }
  var joins             : [ Join ] { []    }
  var isPattern         : Bool     { false }
  var relationshipPath  : String?  { ""    }
}
