//
//  UIKitQueryList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page.UIKit {

  #if !os(iOS)
    static func QueryList() -> some View {
      Text("\(#function) is not available on this platform")
    }
  #else
  /**
   * Shows a page containing the contents of an entity.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This version is intended for iOS.
   */
  struct QueryList: View {
    
    @Environment(\.database)            private var moc
    @Environment(\.entity)              private var entity
    @Environment(\.auxiliaryPredicate)  private var auxiliaryPredicate
    @Environment(\.displayPropertyKeys) private var displayPropertyKeys

    public init() {}

    private func makeDisplayGroup() -> D2SDisplayGroup<NSManagedObject> {
      return D2SDisplayGroup(
        dataSource          : moc.dataSource(for: entity),
        auxiliaryPredicate  : auxiliaryPredicate,
        displayPropertyKeys : displayPropertyKeys
      )
    }
    
    public var body: some View {
      Bound(displayGroup: makeDisplayGroup())
        .environment(\.auxiliaryPredicate, nil) // reset!
    }

    struct Bound<Object: NSManagedObject>: View {
      
      @ObservedObject var displayGroup : D2SDisplayGroup<Object>
      
      @State                                private var showSortSelector = false
      @Environment(\.isEntityReadOnly)      private var isReadOnly
      @Environment(\.debugComponent)        private var debugComponent
      @Environment(\.entity)                private var entity
      @Environment(\.initialPropertyValues) private var initialPropertyValues
      @Environment(\.creationTimestampPropertyKey) private var createTS

      private var sortButtons : [ ActionSheet.Button ] {
        // FIXME: limit in size
        // FIXME: use "displayPropertyKeys" or something
        return entity.d2s.defaultSortPropertyKeys
                 .compactMap { entity[attribute: $0] }
                 .map { attribute in
                   .default(Text(attribute.name.capitalizedWithPreUpperSpace)) {
                      self.displayGroup.sortAttribute = attribute
                   }
                 }
             + [ .cancel { self.displayGroup.sortAttribute = nil } ]
      }
      
      struct RowFaultView<Object: NSManagedObject>: View {
      
        final class ActionModel: ObservableObject {
          @Published var action = D2SObjectAction.nextTask {
            didSet {
              if !isActive && action != .nextTask { isActive = true }
            }
          }
          @Published var isActive = false {
            didSet {
              if isActive == false && action != .nextTask { action = .nextTask }
            }
          }
        }

        typealias Fault = D2SFault<Object, D2SDisplayGroup<Object>>
        
        @ObservedObject var actionModel = ActionModel()
        let fault : Fault

        var body: some View {
          D2SFaultObjectLink(fault    : fault,
                             action   : self.actionModel.action,
                             isActive : self.$actionModel.isActive)
          {
            RowObjectView(action: self.$actionModel.action)
          }
        }
      }

      struct RowObjectView: View {
        
        @Environment(\.rowComponent)      var rowComponent
        @Environment(\.object)            var object
        @Environment(\.isObjectDeletable) var isDeletable
        @Environment(\.isObjectEditable)  var isEditable
        
        @Binding var action : D2SObjectAction
        
        private func inspect() { action = .inspect }
        private func edit()    { action = .edit }
        private func delete()  {
          globalD2SLogger.error("TODO: delete ...")
        }

        var body: some View {
          rowComponent
            .deleteDisabled(!isDeletable)
            .contextMenu {
                               Button("Inspect", action: self.inspect)
              if isDeletable { Button("Delete",  action: self.delete) }
              if isEditable  { Button("Edit",    action: self.edit)   }
            }
        }
      }
      
      private func makeNewRecord() -> NSManagedObject {
        let object = displayGroup.dataSource.createObject()
        for ( k, v ) in initialPropertyValues {
          object.setValue(v, forKeyPath: k)
        }
        if let pkey = createTS {
          object.setValue(Date(), forKey: pkey)
        }
        return object
      }
      
      private func reload() {
        displayGroup.reload()
      }
      
      var body: some View {
        VStack(spacing: 0) {
          SearchField(search: $displayGroup.queryString)
          
          List(displayGroup.results) { fault in
            RowFaultView(fault: fault)
          }
          
          debugComponent
        }
        .actionSheet(isPresented: $showSortSelector) {
          ActionSheet(title: Text("Sort By:"), buttons: sortButtons)
        }
        .navigationBarItems(trailing:
          HStack {
            Button(action: self.reload) {
              Image(systemName: "arrow.2.circlepath.circle")
            }
            Button(action: { self.showSortSelector.toggle() }) {
              Image(systemName: "arrow.up.arrow.down.circle")
            }
            if !isReadOnly {
              // TBD: Embed in NavLink?
              D2SNavigationLink(destination:
                D2SPageView()
                  .ruleObject(makeNewRecord())
                  .task(.edit))
              {
                Image(systemName: "plus.circle")
              }
            }
          }
        )
      }
    }
  }
  #endif // iOS
}
