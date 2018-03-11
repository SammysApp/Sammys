//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladItemType {
    case size, lettuce, vegetable, topping, dressing, extra
}

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
    
    var itemGroups: [ItemGroup] {
        var itemGroups = [ItemGroup]()
        
        guard let size = size else {
            return itemGroups
        }
        itemGroups.append(ItemGroup(title: SaladItemType.size.title, items: [size]))
        
        let saladItems: [[Item]] = [lettuce, vegetables, toppings, dressings, extras]
        saladItems.forEach { items in
            if !items.isEmpty, let firstItem = items.first {
                let item = Swift.type(of: firstItem)
                itemGroups.append(ItemGroup(title: item.type.title, items: items))
            }
        }
        return itemGroups
    }
}

// MARK: - Equatable
extension Salad: Equatable {
    static func ==(lhs: Salad, rhs: Salad) -> Bool {
        return lhs.size == rhs.size && lhs.lettuce == rhs.lettuce && lhs.vegetables == rhs.vegetables && lhs.toppings == rhs.toppings && lhs.dressings == rhs.dressings
    }
}

extension SaladItemType: ItemType {
    var title: String {
        switch self {
        case .size: return "Size"
        case .lettuce: return "Lettuce"
        case .vegetable: return "Vegetables"
        case .topping: return "Toppings"
        case .dressing: return "Dressings"
        case .extra: return "Extras"
        }
    }
}
