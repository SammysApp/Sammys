//
//  Food.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a group of items.
struct ItemGroup {
    /// The title of the group.
    let title: String
    
    /// The type of the group.
    let type: ItemType
    
    /// The items in the group.
    let items: [Item]
}

/// A type that represents a food 🍎 item for sale.
protocol Food: class, Codable {
    /// The type of `Food` conforming type represented by `FoodType` keys.
    static var type: FoodType { get }
    
    /// A unique id to identify an instance of the type.
    var id: String { get }
    
    /// A short title.
    var title: String { get }
    
    var userTitle: String? { get set }
    
    /// A quantity of the `Food` item to buy.
    var quantity: Int { get set }
    
    /// Returns the total price of the `Food` item for a given quantity.
    var price: Double { get }
    
    /// A description of the `Food` item.
    var itemDescription: String { get }
    
    /// An array of item groups belonging to the `Food`.
    var itemGroups: [ItemGroup] { get }
}

extension Food {
    /**
     Use to check if two types conforming to `Food` are equal.
     - Parameter food: `food` to compare `self` to.
     - Returns: `true` if equal, `false` if not.
    */
    func isEqual(_ food: Food) -> Bool {
        if let selfSalad = self as? Salad, let foodSalad = food as? Salad {
            return selfSalad == foodSalad
        }
        return false
    }
}

/**
 A type that identifies types conforming to `Food`.
 - `salad`: identifies `Salad` type.
 */
enum FoodType: String, Codable {
   case salad
    
    /// A reference to the type identified by `self`'s value.
    var metatype: Food.Type {
        switch self {
        case .salad:
            return Salad.self
        }
    }
    
    var title: String {
        switch self {
        case .salad: return "Salad"
        }
    }
}

/// `Food` type erasure that can be used for `Codable` encoding and decoding.
struct AnyFood: Codable {
    let food: Food
    
    init(_ food: Food) {
        self.food = food
    }
    
    private enum CodingKeys: CodingKey {
        case type, food
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(FoodType.self, forKey: .type)
        self.food = try type.metatype.init(from: container.superDecoder(forKey: .food))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type(of: food).type, forKey: .type)
        try food.encode(to: container.superEncoder(forKey: .food))
    }
}

extension Dictionary where Key == FoodType, Value == [Food] {
    var quantity: Int {
        return reduce(0) { $0 + $1.value.count }
    }
    
    var randomFood: Food? {
        // FIXME: crashed index out of range
        let foods = Array(values)[Int(arc4random_uniform(UInt32(count)))]
        return foods[Int(arc4random_uniform(UInt32(foods.count)))]
    }
}
