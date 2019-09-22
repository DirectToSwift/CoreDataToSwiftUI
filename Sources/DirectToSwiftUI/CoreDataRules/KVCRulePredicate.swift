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

  func evaluate(in ruleContext: RuleContext) -> Bool {
    // FIXME
    return evaluateWith(object: ruleContext)
  }
  
}

// TBD: I think conformance has to be declared manually and can't be attached
//      to the protocol?

extension NSCompoundPredicate {  
  public var rulePredicateComplexity : Int {
    return qualifiers.reduce(0) {
      let complexity = ($1 as? RulePredicate)?.rulePredicateComplexity ?? 1
      return $0 + complexity
    }
  }
}

public extension SwiftUIRules.RuleComparisonOperation {
  
  init?(_ op: NSComparisonPredicate.Operator) {
    // FIX case in ZeeQL, which is quite hard as the cases can't be
    // deprecated & aliased?
    switch op {
      case .Unknown, .Contains, .Like, .CaseInsensitiveLike,
           .SQLLike, .SQLCaseInsensitiveLike:
        return nil
      case .EqualTo:            self = .equal
      case .NotEqualTo:         self = .notEqual
      case .GreaterThan:        self = .greaterThan
      case .GreaterThanOrEqual: self = .greaterThanOrEqual
      case .LessThan:           self = .lessThan
      case .LessThanOrEqual:    self = .lessThanOrEqual
    }
  }
}

public extension NSComparisonPredicate.Operator {
  
  init(_ op: SwiftUIRules.RuleComparisonOperation) {
    switch op {
      case .equal:              self = .EqualTo
      case .notEqual:           self = .NotEqualTo
      case .lessThan:           self = .LessThan
      case .greaterThan:        self = .GreaterThan
      case .lessThanOrEqual:    self = .LessThanOrEqual
      case .greaterThanOrEqual: self = .GreaterThanOrEqual
    }
  }
  
}
