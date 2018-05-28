//
//  Size.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents the size 🥣 for a `Salad` instance.
struct Size: Item, Codable, Equatable {
    static let type: ItemType = SaladItemType.size
    let name: String
    let description: String
    let price: Double?
    var modifiers: [Modifier]? = nil
    let hex: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, price, hex
    }
    
    static func ==(lhs: Size, rhs: Size) -> Bool {
        return lhs.name == rhs.name
    }
}
