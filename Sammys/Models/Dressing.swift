//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a dressing 🍶 in a `Salad` instance.
struct Dressing: Item, Codable, Equatable {
    static let type: ItemType = SaladItemType.dressing
    let name: String
    let description: String
    let price: Double? = nil
    var modifiers: [Modifier]?
    let hex: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, modifiers, hex
    }
    
    static func ==(lhs: Dressing, rhs: Dressing) -> Bool {
        return lhs.name == rhs.name
    }
}
