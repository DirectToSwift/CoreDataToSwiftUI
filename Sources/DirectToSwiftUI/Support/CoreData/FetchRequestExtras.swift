//
//  FetchRequestExtras.swift
//  CoreDataToSwiftUI
//
//  Created by Helge Heß on 23.09.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CoreData

public extension NSFetchRequest {

  @objc func typedCopy() -> NSFetchRequest<ResultType> {
    let me = copy()
    guard let typed = me as? NSFetchRequest<ResultType> else {
      fatalError("fetch request lost its type! \(type(of: me))")
    }
    return typed
  }
  
  @objc func limit(_ limit: Int) -> NSFetchRequest<ResultType> {
    let fr = typedCopy()
    fr.fetchLimit = limit
    return fr
  }
  
}
