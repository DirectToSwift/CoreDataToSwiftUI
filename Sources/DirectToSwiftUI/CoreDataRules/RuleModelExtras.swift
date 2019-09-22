//
//  RuleModelExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUIRules
import Foundation

public extension RuleModel {

  @discardableResult
  func when<K>(_ qualifier: NSPredicate,
               set key: K.Type, to value: K.Value) -> Self
         where K: DynamicEnvironmentKey
  {
    guard let predicate = qualifier as? RulePredicate else {
      globalD2SLogger.error("Not a rule compatible qualifier:", qualifier)
      assertionFailure("This qualifier cannot be evaluated in memory!")
      return self
    }
    addRule(Rule(when: predicate,
                 do: RuleValueAssignment(key, value)))
    return self
  }

}
