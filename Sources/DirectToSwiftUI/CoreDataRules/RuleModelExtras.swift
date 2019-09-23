//
//  RuleModelExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class Foundation.NSPredicate
import SwiftUIRules

public extension RuleModel {

  @discardableResult
  func when<K>(_ predicate: NSPredicate,
               set key: K.Type, to value: K.Value) -> Self
         where K: DynamicEnvironmentKey
  {
    addRule(Rule(when: predicate,
                 do: RuleValueAssignment(key, value)))
    return self
  }
}
