//
//  Vegetable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a vegetable 🥦 or fruit 🥑 in a `Salad` instance.
struct Vegetable: Item, Codable, Equatable {
    static let type: ItemType = SaladItemType.vegetable
    let name: String
    let description: String
    let price: Double? = nil
    var modifiers: [Modifier]? = nil
    let hex: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, hex
    }
    
    static func ==(lhs: Vegetable, rhs: Vegetable) -> Bool {
        return lhs.name == rhs.name
    }
}
