//
//  SmallQueryList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page {
  /**
   * Shows a page containing the contents of an entity.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This simple variant is intended for watchOS.
   */
  struct SmallQueryList: View {
    
    @Environment(\.database)           private var moc
    @Environment(\.entity)             private var entity
    @Environment(\.auxiliaryQualifier) private var auxiliaryQualifier
    
    public init() {}

    private func makeDataSource() -> ManagedObjectDataSource<NSManagedObject> {
      moc.dataSource(for: entity)
    }
    
    public var body: some View {
      Bound(dataSource: makeDataSource(),
            auxiliaryQualifier: auxiliaryQualifier)
        .environment(\.auxiliaryQualifier, nil) // reset!
    }

    struct Bound<Object: NSManagedObject>: View {

      // This seems to crash on macOS b7
      @ObservedObject private var displayGroup : D2SDisplayGroup<Object>
      
      init(dataSource         : ManagedObjectDataSource<Object>,
           auxiliaryQualifier : NSPredicate?)
      {
        self.displayGroup = D2SDisplayGroup(
          dataSource         : dataSource,
          auxiliaryQualifier : auxiliaryQualifier
        )
      }

      var body: some View {
        VStack {
          List(displayGroup.results) { fault in
            D2SFaultObjectLink(fault: fault)
          }
        }
      }
    }
  }
}
