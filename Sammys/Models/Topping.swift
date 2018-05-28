//
//  Topping.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a topping 🥜 in a `Salad` instance.
struct Topping: Item, Codable, Equatable {
    static let type: ItemType = SaladItemType.topping
    let name: String
    let description: String
    let price: Double?
    var modifiers: [Modifier]? = nil
    let hex: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, price, hex
    }
    
    static func ==(lhs: Topping, rhs: Topping) -> Bool {
        return lhs.name == rhs.name
    }
}
