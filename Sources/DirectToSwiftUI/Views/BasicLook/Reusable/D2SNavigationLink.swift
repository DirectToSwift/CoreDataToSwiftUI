//
//  D2SNavigationLink.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * The same like `NavigationLink`, but this preserves the `D2SContext`
 * in the environment OF THE DESTINATION. Which otherwise starts with
 * a fresh one!
 *
 * On b6 watchOS/macOS the environment is lost on navigation.
 * That is no good :-) So we copy our keys (which are all stored within the
 * D2SContext).
 */
public struct D2SNavigationLink<Label, Destination>: View
         where Label: View, Destination: View
{
  @Environment(\.ruleContext) private var context
  @Environment(\.managedObjectContext) private var moc

  private let destination : Destination
  private let label       : Label
  private let isActive    : Binding<Bool>?
  
  public init(destination: Destination,
              isActive: Binding<Bool>? = nil,
              @ViewBuilder label: () -> Label)
  {
    self.destination = destination
    self.label    = label()
    self.isActive = isActive
  }
  
  public var body: some View {
    Group {
      if isActive != nil {
        NavigationLink(destination: destination
                                      .environmentObject(context.object)
                                      .environment(\.managedObjectContext, moc)
                                      .ruleContext(context),
                       isActive: isActive!)
        {
          label
            .environmentObject(context.object)
            .environment(\.managedObjectContext, moc)
            .ruleContext(context)
        }
      }
      else {
        NavigationLink(destination: destination
                                      .environmentObject(context.object)
                                      .environment(\.managedObjectContext, moc)
                                      .ruleContext(context))
        {
          label
            .environmentObject(context.object)
            .environment(\.managedObjectContext, moc)
            .ruleContext(context)
        }
      }
    }
  }
}
