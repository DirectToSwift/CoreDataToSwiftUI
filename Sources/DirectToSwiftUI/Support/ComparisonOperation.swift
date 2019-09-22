//
//  ComparisonOperation.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 22.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation

extension NSComparisonPredicate.Operator: Equatable {

  public static func ==(lhs: NSComparisonPredicate.Operator,
                        rhs: NSComparisonPredicate.Operator)
                     -> Bool
  {
    switch ( lhs, rhs ) {
      case ( equalTo,                equalTo                ): return true
      case ( notEqualTo,             notEqualTo             ): return true
      case ( greaterThan,            greaterThan            ): return true
      case ( greaterThanOrEqualTo,   greaterThanOrEqualTo   ): return true
      case ( lessThan,               lessThan               ): return true
      case ( lessThanOrEqualTo,      lessThanOrEqualTo      ): return true
      case ( contains,               contains               ): return true
      case ( between,                between                ): return true
      case ( like,                   like                   ): return true
      case ( beginsWith,             beginsWith             ): return true
      case ( endsWith,               endsWith               ): return true
      case ( matches,                matches                ): return true
      case ( customSelector,         customSelector         ): return true //TBD
    }
  }
}

public extension NSComparisonPredicate.Operator {
  // TODO: Evaluation is a "little" harder in Swift, also coercion
  // Note: Had this as KeyValueQualifier<T>, but this makes class-checks harder.
  //       Not sure what the best Swift approach would be to avoid the Any

  func compare(_ a: Any?, _ b: Any?) -> Bool {
    // Everytime you compare an Any, a 🐄 dies.
    switch self {
      case .equalTo:            return eq(a, b)
      case .notEqualTo:         return !eq(a, b)
      case .lessThan:           return isSmaller(a, b)
      case .greaterThan:        return isSmaller(b, a)
      case .lessThanOrEqual:    return isSmaller(a, b) || eq(a, b)
      case .greaterThanOrEqual: return isSmaller(b, a) || eq(a, b)
      
      case .contains: // firstname in ["donald"] or firstname in "donald"
        guard let b = b else { return false }
        guard let list = b as? ContainsComparisonType else {
          globalD2SLogger.error(
            "attempt to evaluate an ComparisonOperation dynamically:",
            self, a, b
          )
          assertionFailure("comparison not supported for dynamic evaluation")
          return false
        }
        return list.contains(other: a)
      
      case .like, .caseInsensitiveLike: // firstname like *Donald*
        let ci = self == .CaseInsensitiveLike
        if a == nil && b == nil { return true } // nil is like nil
        guard let value = a as? LikeComparisonType else {
          globalD2SLogger.error(
            "attempt to evaluate an ComparisonOperation dynamically:",
            self, a, b
          )
          assertionFailure("comparison not supported for dynamic evaluation")
          return false
        }
        return value.isLike(other: b, caseInsensitive: ci)

      // TODO: support many more, geez :-)
      
      default:
        globalD2SLogger.error(
          "attempt to evaluate an ComparisonOperation dynamically:",
          self, a, b
        )
        assertionFailure("comparison not supported for dynamic evaluation")
        return false
    }
  }
}
