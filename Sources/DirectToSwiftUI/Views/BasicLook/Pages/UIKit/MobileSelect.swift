//
//  UIKitSelect.swift
//  DirectToSwift
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page.UIKit {

#if !os(iOS)
  static func Select() -> some View {
    Text("\(#function) is not available on this platform")
  }
#else

  /**
   * Edit a relationship.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This version is intended for iOS.
   */
  struct Select: View {
    // Note: This is _almost_ a dupe of the QueryList page. But not quite.

    @Environment(\.ruleObjectContext)   private var moc
    @Environment(\.entity)              private var entity
    @Environment(\.auxiliaryPredicate)  private var auxiliaryPredicate
    @Environment(\.displayPropertyKeys) private var displayPropertyKeys
    @Environment(\.relationship)        private var relationship
    @EnvironmentObject private var sourceObject : NSManagedObject

    public init() {}

    private func makeDisplayGroup() -> D2SDisplayGroup<NSManagedObject> {
      return D2SDisplayGroup(
        dataSource          : moc.dataSource(for: entity),
        auxiliaryPredicate  : auxiliaryPredicate,
        displayPropertyKeys : displayPropertyKeys
      )
    }
    
    private var selectedID: NSManagedObjectID? {
      sourceObject.objectIDs(forRelationshipNamed: relationship.name).first
    }
    
    public var body: some View {
      // Right now we only do single-select aka toOne
      Group {
        if relationship.isToMany {
          Text("Not supporting\nToMany selection\njust yet.")
        }
        else {
          SingleSelect(displayGroup: makeDisplayGroup(),
                       sourceObject: sourceObject,
                       initialID: selectedID)
            .environment(\.auxiliaryPredicate, nil) // reset!
        }
      }
    }

    struct SingleSelect<Object: NSManagedObject>: View {

      typealias Fault = D2SFault<Object, D2SDisplayGroup<Object>>

      @ObservedObject var displayGroup : D2SDisplayGroup<Object>
      @ObservedObject var sourceObject : NSManagedObject
      
      @Environment(\.relationship)     private var relationship

      @Environment(\.entity)           private var entity
      @Environment(\.debugComponent)   private var debugComponent
      @Environment(\.rowComponent)     private var rowComponent
      @Environment(\.presentationMode) private var presentationMode

      @State var selectedID     : NSManagedObjectID?
      @State var isShowingError = false
      
      init(displayGroup : D2SDisplayGroup<Object>,
           sourceObject : NSManagedObject,
           initialID    : NSManagedObjectID?)
      {
        self.displayGroup = displayGroup
        self.sourceObject = sourceObject
        self._selectedID  = State(initialValue: initialID)
      }
      
      private var selectedObject: Object? {
        guard let id = selectedID else { return nil }
        return displayGroup.results[id]
      }
      
      private func goBack() {
        presentationMode.wrappedValue.dismiss()
      }

      private func saveSelection() {
        assert(relationship !== D2SKeys.relationship.defaultValue,
               "called w/ default relationship")
        
        if let targetObject = selectedObject {
          sourceObject.wire(destination: targetObject, to: relationship)
          goBack()
        }
        else if selectedID != nil {
          globalD2SLogger.error("object not yet fetched:", selectedID)
          isShowingError = true
        }
        else { // nil case
          sourceObject.wire(destination: nil, to: relationship)
          goBack()
        }
      }
      
      private var isValid: Bool {
        if !relationship.isOptional && selectedID == nil { return false }
        return true
      }
      
      private func errorAlert() -> Alert {
        Alert(title: Text("Missing Object"),
              message: Text("Selection not available"),
              dismissButton: .default(Text("🤷‍♀️")))
      }
      
      var body: some View {
        VStack(spacing: 0) {
          SearchField(search: $displayGroup.queryString)
          
          List(displayGroup.results, selection: $selectedID) { fault in
            D2SFaultContainer(fault: fault) { object in
              self.rowComponent
                .tag(object.objectID)
            }
          }
          .environment(\.editMode, .constant(EditMode.active)) // required

          debugComponent
        }
        .alert(isPresented: $isShowingError, content: errorAlert)
        .navigationBarItems(trailing:
          HStack {
            Button(action: self.saveSelection) {
              Text("Apply")
            }
            .disabled(!isValid)
          }
        )
      }
    }
  }
#endif // iOS
}
