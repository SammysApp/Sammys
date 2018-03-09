//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a salad 🥗 `Food` type.
class Salad: Food {
    /// The size of the salad. Default is `nil`.
    var size: Size?
    
    /// The lettuces for the salad.
    var lettuce: [Lettuce] = []
    
    /// The vegetables for the salad.
    var vegetables: [Vegetable] = []
    
    /// The toppings for the salad.
    var toppings: [Topping] = []
    
    /// The dressings for the salad.
    var dressings: [Dressing] = []
    
    /// The extras for the salad.
    var extras: [Extra] = []
    
    // MARK: - Food
    static let type = FoodType.salad
    var id = UUID().uuidString
    
    /// The quantity of salads to buy. Determines `price` value. Default is `1`.
    var quantity = 1
    
    /// Returns title for salad.
    var title: String {
        return "\(size!.name) Salad"
    }
}

extension Salad {
    /// Returns product of the salad's base price and `quantity`. If `size` is `nil` returns `0`.
    var price: Double {
        get {
            return size?.price != nil ? size!.price * Double(quantity) : 0
        }
    }
    
    var itemDescription: String {
        return (lettuce as [Item] + vegetables as [Item] + toppings as [Item] + dressings as [Item]).commaString
    }
    
    var itemDictionary: ItemsDictionary {
        var dictionary: ItemsDictionary = [:]
        guard let size = size else {
            return dictionary
        }
        
        var index = 0
        /**
         Returns index and then increments by 1. Used in order to get the proper index key to set the value to in `dictionary`.
         */
        func getIndex() -> Int {
            defer {
                index += 1
            }
            return index
        }
        
        dictionary[getIndex()] = ("Size", [size])
        dictionary[getIndex()] = ("Lettuce", lettuce)
        if !vegetables.isEmpty { dictionary[getIndex()] = ("Vegetables", vegetables) }
        if !toppings.isEmpty { dictionary[getIndex()] = ("Toppings", toppings) }
        if !dressings.isEmpty { dictionary[getIndex()] = ("Dressings", dressings) }
        if !extras.isEmpty { dictionary[getIndex()] = ("Extras", extras) }
        
        return dictionary
    }
}

// MARK: - Equatable
extension Salad: Equatable {
    static func ==(lhs: Salad, rhs: Salad) -> Bool {
        return lhs.size == rhs.size && lhs.lettuce == rhs.lettuce && lhs.vegetables == rhs.vegetables && lhs.toppings == rhs.toppings && lhs.dressings == rhs.dressings
    }
}
