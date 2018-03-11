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
    
    static func ==(lhs: Topping, rhs: Topping) -> Bool {
        return lhs.name == rhs.name
    }
}
