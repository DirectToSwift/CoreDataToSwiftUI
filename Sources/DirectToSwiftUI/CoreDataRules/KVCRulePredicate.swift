//
//  KVCRulePredicate.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation
import protocol SwiftUIRules.RulePredicate
import struct   SwiftUIRules.RuleContext

extension NSPredicate : RulePredicate {

  public func evaluate(in ruleContext: RuleContext) -> Bool {
    // FIXME: need to wrap ruleContext in KVC trampoline
    evaluate(with: ruleContext)
  }
  
}

// TBD: I think conformance has to be declared manually and can't be attached
//      to the protocol?

extension NSCompoundPredicate {  
  public var rulePredicateComplexity : Int {
    return subpredicates.reduce(0) {
      let complexity = ($1 as? RulePredicate)?.rulePredicateComplexity ?? 1
      return $0 + complexity
    }
  }
}

public extension SwiftUIRules.RuleComparisonOperation {
  
  init?(_ op: NSComparisonPredicate.Operator) {
    switch op {
      case .matches, .like, .beginsWith, .endsWith,
           .`in`, .customSelector, .contains, .between:
        return nil
      case .equalTo:              self = .equal
      case .notEqualTo:           self = .notEqual
      case .greaterThan:          self = .greaterThan
      case .greaterThanOrEqualTo: self = .greaterThanOrEqual
      case .lessThan:             self = .lessThan
      case .lessThanOrEqualTo:    self = .lessThanOrEqual
      @unknown default: return nil
    }
  }
}

public extension NSComparisonPredicate.Operator {
  
  init(_ op: SwiftUIRules.RuleComparisonOperation) {
    switch op {
      case .equal:              self = .equalTo
      case .notEqual:           self = .notEqualTo
      case .lessThan:           self = .lessThan
      case .greaterThan:        self = .greaterThan
      case .lessThanOrEqual:    self = .lessThanOrEqualTo
      case .greaterThanOrEqual: self = .greaterThanOrEqualTo
    }
  }
}
