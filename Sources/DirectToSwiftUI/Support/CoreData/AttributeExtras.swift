//
//  AttributeExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation
import CoreData

public extension NSAttributeDescription {
  var isPassword : Bool {
    let lc = name.lowercased()
    return lc.contains("password") || lc.contains("passwd")
  }
}

public extension NSAttributeDescription {
  // TODO: Check width and such.
  // TODO: Belongs into ZeeQL (and should also be called by AR)
  
  func validateForInsert(_ object: KeyValueCodingType?) -> Bool {
    guard let object = object else { return false }
    if !isOptional, KeyValueCoding.value(forKey: name, inObject: object) == nil
    {
      return false
    }
    return true
  }
  func validateForUpdate(_ object: KeyValueCodingType?) -> Bool {
    guard let object = object else { return false }
    if !isOptional, KeyValueCoding.value(forKey: name, inObject: object) == nil
    {
      return false
    }
    return true
  }
}

public extension NSRelationshipDescription {
  
  func validateForInsert(_ object: KeyValueCodingType?) -> Bool {
    return validateForUpdate(object)
  }
  
  func validateForUpdate(_ object: KeyValueCodingType?) -> Bool {
    guard let object = object else { return false }
    if isOptional { return true }
    
    let target = KeyValueCoding.value(forKeyPath: name, inObject: object)
    return target != nil
  }
}

fileprivate let ddateFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()
fileprivate let timeFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .none
  df.timeStyle = .medium
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()
internal let dateTimeFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .medium
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()

public extension NSAttributeDescription {
  
  func dateFormatter() -> DateFormatter {
    dateTimeFormatter
  }
  
}

enum D2SAttributeCoercionError: Swift.Error {
  case failedToCoerceFromString(String?, Attribute)
}

public extension NSAttributeDescription {
  
  func coerceFromString(_ string: String?) throws -> Any? {
    func logError() throws -> Any? {
      throw D2SAttributeCoercionError.failedToCoerceFromString(string, self)
    }
    
    var trimmed : String? {
      guard let s = string else { return nil }
      let t = s.trimmingCharacters(in: .whitespaces)
      return t.isEmpty ? nil : t
    }
    func coerce<I: FixedWidthInteger>(to type: I.Type) throws -> Any? {
      guard let s = trimmed else { return try logError() }
      guard let i = I(s)    else { return try logError() }
      return i
    }
    func coerceOpt<I: FixedWidthInteger>(to type: I.Type) throws -> Any? {
      guard let s = trimmed else { return nil }
      guard let i = I(s)    else { return try logError() }
      return i
    }
    
    // ☢️ QUICK: LOOK AWAY. Dirty dirty stuff ahead! ☢️
    
    switch attributeType {
    
      case .stringAttributeType:
        guard let s = string else { return isOptional ? nil : try logError() }
        return s
        
      case .integer64AttributeType:
        return isOptional ? try coerceOpt(to: Int64.self)
                          : try coerce   (to: Int64.self)
      case .integer32AttributeType:
        return isOptional ? try coerceOpt(to: Int32.self)
                          : try coerce   (to: Int32.self)
      case .integer16AttributeType:
        return isOptional ? try coerceOpt(to: Int16.self)
                          : try coerce   (to: Int16.self)

      case .dateAttributeType:
        guard let s = trimmed else { return isOptional ? nil : try logError() }
        guard let v = dateFormatter().date(from: s) else { return try logError() }
        return v
        
      case .booleanAttributeType:
        guard let s = trimmed?.lowercased() else {
          return isOptional ? nil : false
        }
        if s.isEmpty { return false }
        if falseStrings.first(where: { s.contains($0)} ) != nil { return false }
        return true
      
      case .doubleAttributeType:
        guard let s = trimmed  else { return isOptional ? nil : try logError() }
        guard let v = Double(s) else { return try logError() }
        return v
      case .floatAttributeType:
        guard let s = trimmed  else { return isOptional ? nil : try logError() }
        guard let v = Float(s) else { return try logError() }
        return v
      case .decimalAttributeType:
        guard let s = trimmed  else { return isOptional ? nil : try logError() }
        guard let v = Decimal(string: s) else { return try logError() }
        return v
        
      case .URIAttributeType:
        guard let s = trimmed  else { return isOptional ? nil : try logError() }
        guard let v = URL(string: s) else { return try logError() }
        return v
      case .UUIDAttributeType:
        guard let s = trimmed  else { return isOptional ? nil : try logError() }
        guard let v = UUID(uuidString: s) else { return try logError() }
        return v

      // Data. Hm, well, what would the Data be, UTF8?

      default: return try logError()
    }
  }
  
}

fileprivate let falseStrings = [
  "no", "false", "nein", "njet", "nada", "nope"
]


// MARK: - Query Builder

public extension NSAttributeDescription {
  
  func eq(_ attr: NSAttributeDescription) -> NSComparisonPredicate {
    NSComparisonPredicate(leftExpression  : NSExpression(forKeyPath: self.name),
                          rightExpression : NSExpression(forKeyPath: attr.name),
                          modifier: .direct, type: .equalTo, options: [])
  }
  
  func eq(_ value : Any?) -> NSComparisonPredicate {
    NSComparisonPredicate(
      leftExpression  : NSExpression(forKeyPath: self.name),
      rightExpression : NSExpression(forConstantValue: value),
      modifier: .direct, type: .equalTo, options: []
    )
  }
}

public extension NSAttributeDescription {
  
  func like(_ pattern : String) -> NSComparisonPredicate {
    NSComparisonPredicate(
      leftExpression  : NSExpression(forKeyPath: self.name),
      rightExpression : NSExpression(forConstantValue: pattern),
      modifier: .direct, type: .like, options: []
    )
  }
  
}
