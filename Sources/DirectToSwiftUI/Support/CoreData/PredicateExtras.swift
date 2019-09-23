//
//  PredicateExtras.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 23.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation

public extension NSPredicate {
  
  var not : NSPredicate {
    NSCompoundPredicate(notPredicateWithSubpredicate: self)
  }
  func or(_ q: NSPredicate?) -> NSPredicate {
    guard let q = q else { return self }
    return NSCompoundPredicate(orPredicateWithSubpredicates: [self, q ])
  }
  func and(_ q: NSPredicate?) -> NSPredicate {
    guard let q = q else { return self }
    return NSCompoundPredicate(andPredicateWithSubpredicates: [self, q ])
  }
}


// MARK: - Factory

public func and(_ a: NSPredicate?, _ b: NSPredicate?) -> NSPredicate? {
  if let a = a, let b = b { return a.and(b) }
  if let a = a { return a }
  return b
}
public func or(_ a: NSPredicate?, _ b: NSPredicate?) -> NSPredicate? {
  if let a = a, let b = b { return a.or(b) }
  if let a = a { return a }
  return b
}
fileprivate func and1(_ a: NSPredicate?, _ b: NSPredicate?) -> NSPredicate? {
  and(a, b)
}
fileprivate func or1(_ a: NSPredicate?, _ b: NSPredicate?) -> NSPredicate? {
  or(a, b)
}

public extension Sequence where Element : NSPredicate {
  
  func and() -> NSPredicate {
    return reduce(nil, { and1($0, $1) }) ?? NSPredicate(value: true)
  }
  func or() -> NSPredicate {
    return reduce(nil, { or1($0, $1) }) ?? NSPredicate(value: false)
  }
  func compactingOr() -> NSPredicate {
    return Array(self).compactingOr()
  }
}
public extension Collection where Element : NSPredicate {
  
  func and() -> NSPredicate {
    if isEmpty { return NSPredicate(value: false) }
    if count == 1 { return self[self.startIndex] }
    return NSCompoundPredicate(andPredicateWithSubpredicates: Array(self))
  }
  func or() -> NSPredicate {
    if isEmpty { return NSPredicate(value: false) }
    if count == 1 { return self[self.startIndex] }
    return NSCompoundPredicate(orPredicateWithSubpredicates: Array(self))
  }
  func compactingOr() -> NSPredicate {
    if isEmpty { return NSPredicate(value: false) }
    if count == 1 { return self[self.startIndex] }
    return Array(self).compactingOr()
  }
}
public extension Array where Element : NSPredicate {
  func compactingOr() -> NSPredicate {
    if isEmpty { return NSPredicate(value: false) }
    if count == 1 { return self[self.startIndex] }
    guard let kva = self as? [ NSComparisonPredicate ] else {
      return NSCompoundPredicate(orPredicateWithSubpredicates: Array(self))
    }
    return kva.compactingOr()
  }
}
public extension Collection where Element == NSComparisonPredicate {
  
  /// TODO: Not implemented for CoreData, maybe not necessary either
  func compactingOr() -> NSPredicate {
    if isEmpty { return NSPredicate(value: false) }
    if count == 1 { return self[self.startIndex] }
    
    #if true
      return NSCompoundPredicate(orPredicateWithSubpredicates: Array(self))
    #else
    var keyToValues = [ String : [ Any? ] ]()
    var extra = [ NSPredicate ]()
    
    for kvq in self {
      if kvq.predicateOperatorType != .equalTo {
        extra.append(kvq)
        continue
      }
      
      let lhs = kvq.leftExpression, rhs = kvq.rightExpression
      if keyToValues[key] == nil { keyToValues[key] = [ value ]    }
      else                       { keyToValues[key]!.append(value) }
    }
    
    for ( key, values ) in keyToValues {
      if values.isEmpty { continue }
      if values.count == 1 {
        extra.append(NSComparisonPredicate(key, .equalTo, values.first!))
      }
      else {
        extra.append(NSComparisonPredicate(key, .Contains, values))
      }
    }
    
    if extra.count == 1 { return extra[extra.startIndex] }
    return NSCompoundPredicate(orPredicateWithSubpredicates: extra)
    #endif
  }
}


public func qualifierToMatchAnyValue(_ values: [ String : Any? ]?,
                                     _ op: NSComparisonPredicate.Operator
                                              = .equalTo,
                                     caseInsensitive: Bool = false)
            -> NSPredicate?
{
  guard let values = values, !values.isEmpty else { return nil }
  let kvq = values.map { key, value in
    NSComparisonPredicate(
      leftExpression  : NSExpression(forKeyPath: key),
      rightExpression : NSExpression(forConstantValue: value),
      modifier: .direct, type: .equalTo,
      options: caseInsensitive ? [ .caseInsensitive ] : []
    )
  }
  if kvq.count == 1 { return kvq[0] }
  return NSCompoundPredicate(orPredicateWithSubpredicates: kvq)
}
