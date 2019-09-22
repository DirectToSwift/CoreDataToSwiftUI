//
//  ReExport.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

@_exported import SwiftUI
@_exported import CoreData
@_exported import SwiftUIRules

infix operator => : AssignmentPrecedence

public let globalD2SLogger = ZeeQL.globalZeeQLLogger
