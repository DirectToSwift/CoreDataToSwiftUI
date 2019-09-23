//
//  D2SDebugEntityDetails.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2SDebugEntityDetails: View {
  
  @Environment(\.entity) var entity
  
  struct AttributeInfo: View {
    
    let attribute: Attribute
    
    var body: some View {
      VStack(alignment: .leading) {
        Text(verbatim: attribute.name)
        
        VStack(alignment: .leading) {
          if attribute.isPattern { Text(verbatim: "*Pattern!") }
          if attribute.columnName != nil &&
             attribute.columnName != attribute.name
          {
            Text(verbatim: attribute.columnName!)
          }
          attribute.externalType .map { Text(verbatim: $0) }
          attribute.attributeType.map { Text(verbatim: String(describing: $0)) }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
      }
      .frame(maxWidth: .infinity)
    }
  }
  
  struct RelationshipInfo: View {
    
    let relationship: Relationship
    
    var body: some View {
      VStack(alignment: .leading) {
        Text(verbatim: relationship.name)
        VStack(alignment: .leading) {
          if relationship.isOptional { Text("Optional") }
          if relationship.isOrdered  { Text("Ordered") }
          Text(relationship.isToMany ? "ToMany" : "ToOne")
          relationship.destinationEntity.map { entity in
            Text(verbatim: entity.name ?? "-")
          }
         /*
         var  entity            : Entity          { get }
         var  destinationEntity : Entity?         { get }

         var  minCount          : Int?            { get }
         var  maxCount          : Int?            { get }

         var  joins             : [ Join ]        { get }
         var  joinSemantic      : Join.Semantic   { get }
         var  updateRule        : ConstraintRule? { get }
         var  deleteRule        : ConstraintRule? { get }
         var  ownsDestination   : Bool            { get }
         var  constraintName     : String?         { get }
          */
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
      }
      .frame(maxWidth: .infinity)
    }
    
  }

  public var body: some View {
    D2SDebugBox {
      if entity.d2s.isDefault {
        Text("No Entity set")
      }
      else {
        Text(verbatim: entity.displayNameWithExternalName)
          .font(.title)
        
        ForEach(entity.attributes, id: \.name) { attribute in
          AttributeInfo(attribute: attribute)
        }
        
        ForEach(entity.relationships, id: \.name) { relationship in
          RelationshipInfo(relationship: relationship)
        }
      }
    }
  }
}
