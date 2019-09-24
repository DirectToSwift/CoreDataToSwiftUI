//
//  KeyValueCodingType.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 22.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation

public enum KeyValueCoding {

  static func setValue(_ value: Any?, forKey key: String,
                       inObject object: KeyValueCodingType?)
  {
    guard let object = object else { return }
    object.setValue(value, forKey: key)
  }
  static func value(forKey key: String,
                    inObject object: KeyValueCodingType?) -> Any?
  {
    guard let object = object else { return nil }
    return object.value(forKey: key)
  }

  static func setValue(_ value: Any?, forKeyPath path: String,
                       in object: KeyValueCodingType?)
  {
    guard let object = object else { return }
    object.setValue(value, forKeyPath: path)
  }
  static func value(forKeyPath path: String,
                    inObject object: KeyValueCodingType?) -> Any?
  {
    guard let object = object else { return nil }
    return object.value(forKeyPath: path)
  }

}

public protocol KeyValueCodingType {
  func setValue(_ value: Any?, forKey key: String)
  func value(forKey key: String) -> Any?

  func setValue(_ value: Any?, forKeyPath path: String)
  func value(forKeyPath path: String) -> Any?
}

extension NSObject: KeyValueCodingType {}

public extension KeyValueCodingType {

  func setValue(_ value: Any?, forKeyPath path: String) {
    guard let r = path.range(of: ".") else {
      return setValue(value, forKey: path)
    }
    let k1 = String(path[..<r.lowerBound])
    guard let child = self.value(forKey: k1) else { return }
    
    guard let kvcChild = child as? KeyValueCodingType else {
      globalD2SLogger.warn("child is not a KVC type:", child, "for:", path)
      assertionFailure("child is not a KVC type: \(child)")
      return
    }
    kvcChild.setValue(value, forKeyPath: String(path[r.upperBound...]))
  }
  
  func value(forKeyPath path: String) -> Any? {
    guard let r = path.range(of: ".") else { return value(forKey: path) }

    let k1 = String(path[..<r.lowerBound])
    guard let child = self.value(forKey: k1) else { return nil }
    
    guard let kvcChild = child as? KeyValueCodingType else {
      globalD2SLogger.warn("child is not a KVC type:", child, "for:", path)
      assertionFailure("child is not a KVC type: \(child)")
      return nil
    }
    return kvcChild.value(forKeyPath: String(path[r.upperBound...]))
  }
}

@dynamicMemberLookup
public struct KVCTrampoline : EquatableType, Equatable {
  
  // TBD: This could also wrap the result in another KVCTrampoline. It
  //      currently doesn't allow this: object.address.street,
  //      because we just return Any?.
  //      On the other hand, we would probably have to add noop KeyValueCoding
  //      to the base types.

  public let object : KeyValueCodingType
  
  public subscript(dynamicMember member: String) -> KVCTrampoline? {
    set { object.setValue(newValue, forKey: member) }
    get {
      guard let v = object.value(forKey: member) else { return nil }
      guard let kvc = v as? KeyValueCodingType else {
        globalD2SLogger.warn("using non-kvc type w/ dyn keypathes:", v,
                             type(of: v))
        return KVCTrampoline(object: KVCBox(value: v))
      }
      return KVCTrampoline(object: kvc)
    }
  }
  
  public func isEqual(to object: Any?) -> Bool {
    if let other = object as? KVCTrampoline {
      return eq(self.object, other.object)
    }
    return eq(self.object, object)
  }
  
  public static func ==(lhs: KVCTrampoline, rhs: KVCTrampoline) -> Bool {
    return eq(lhs.object, rhs.object)
  }
}

public struct KVCBox: KeyValueCodingType {
  public let value : Any
  
  public func setValue(_ value: Any?, forKey key: String) {
    globalD2SLogger.warn("KVCBox cannot set value for key:", key,
                         "on:", self.value)
  }
  public func value(forKey key: String) -> Any? {
    if key == "self" { return value }
    globalD2SLogger.warn("KVCBox cannot get value for key:", key,
                         "from:", value)
    return nil
  }
}
