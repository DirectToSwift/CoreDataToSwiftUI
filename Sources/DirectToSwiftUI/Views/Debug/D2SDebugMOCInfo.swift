//
//  D2SDebugMOCInfo.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2SDebugMOCInfo: View {
  
  @Environment(\.database) var moc

  public var body: some View {
    D2SDebugBox {
      if moc.d2s.isDefault {
        Text("Dummy MOC!")
      }
      else {
        Text(verbatim: moc.d2s.defaultTitle)
          .font(.title)
        Text(verbatim: "\(moc)")
        (moc.persistentStoreCoordinator?.managedObjectModel).flatMap {
          Text("Model: #\($0.entities.count) entities")
        }
        moc.persistentStoreCoordinator.flatMap {
          Text(verbatim: "\($0)")
        }
      }
    }
  }
}
