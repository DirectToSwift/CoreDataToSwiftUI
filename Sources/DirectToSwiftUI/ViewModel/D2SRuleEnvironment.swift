//
//  D2SRuleEnvironment.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class  SwiftUIRules.RuleModel
import struct SwiftUIRules.RuleContext
import SwiftUI
import Combine
import CoreData

/**
 * Used to fetch the model from the database, if necessary.
 */
public final class D2SRuleEnvironment: ObservableObject {
  
  public var isReady  : Bool { databaseModel != nil }
  public var hasError : Bool { error         != nil }

  @Published public var databaseModel : NSManagedObjectModel?
  @Published public var error         : Swift.Error?
  @Published public var ruleContext   : RuleContext
  
  public let managedObjectContext     : NSManagedObjectContext
  public let ruleModel                : RuleModel

  public init(managedObjectContext : NSManagedObjectContext,
              ruleModel            : RuleModel)
  {
    self.managedObjectContext = managedObjectContext
    self.databaseModel =
           managedObjectContext.persistentStoreCoordinator?.managedObjectModel
    self.ruleModel            = ruleModel
    
    ruleContext = RuleContext(ruleModel: ruleModel)
    ruleContext[D2SKeys.database] = managedObjectContext
    
    if let model = self.databaseModel {
      ruleContext[D2SKeys.model] = model
    }
  }
  
  public func resume() {}
}
