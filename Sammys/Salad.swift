//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Salad: Food {
    static let type = FoodType.salad
    let id = UUID().uuidString
    var title: String {
        return "\(size!.name) Salad"
    }
    var size: Size?
    var lettuce: [Lettuce] = []
    var vegetables: [Vegetable] = []
    var toppings: [Topping] = []
    var dressings: [Dressing] = []
    var extras: [Extra] = []
    var quantity = 1
}

extension Salad: Equatable {
    static func ==(lhs: Salad, rhs: Salad) -> Bool {
        return lhs.size == rhs.size && lhs.lettuce == rhs.lettuce && lhs.vegetables == rhs.vegetables && lhs.toppings == rhs.toppings && lhs.dressings == rhs.dressings
    }
}

extension Salad {
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
         Returns index and then increments by 1. Use in order to get the next index to place property in in `dictionary`.
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

extension Array where Element == Item {
    var commaString: String {
        return self.map { $0.name }.joined(separator: ", ")
    }
}
