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
        itemGroups.append(ItemGroup(title: SaladItemType.size.title, type: SaladItemType.size, items: [size]))
        
        let saladItems: [[Item]] = [lettuce, vegetables, toppings, dressings, extras]
        saladItems.forEach { items in
            if !items.isEmpty, let firstItem = items.first {
                let item = Swift.type(of: firstItem)
                itemGroups.append(ItemGroup(title: item.type.title, type: item.type, items: items))
            }
        }
        return itemGroups
    }
}

// MARK: Helpers
extension Salad {
    func toggle(_ item: Item) {
        switch item {
        case let lettuce as Lettuce:
            if self.lettuce.contains(lettuce) {
                self.lettuce.remove(lettuce)
            } else {
                self.lettuce.append(lettuce)
            }
        case let vegetable as Vegetable:
            if vegetables.contains(vegetable) {
                vegetables.remove(vegetable)
            } else {
                vegetables.append(vegetable)
            }
        case let topping as Topping:
            if toppings.contains(topping) {
                toppings.remove(topping)
            } else {
                toppings.append(topping)
            }
        case let dressing as Dressing:
            if dressings.contains(dressing) {
                dressings.remove(dressing)
            } else {
                dressings.append(dressing)
            }
        default: break
        }
    }
}

// MARK: - Equatable
extension Salad: Equatable {
    static func ==(lhs: Salad, rhs: Salad) -> Bool {
        return lhs.size == rhs.size && lhs.lettuce == rhs.lettuce && lhs.vegetables == rhs.vegetables && lhs.toppings == rhs.toppings && lhs.dressings == rhs.dressings
    }
}

extension SaladItemType: ItemType {
    enum SaladItemName: String {
        case Size, Lettuce, Vegetables, Toppings, Dressings, Extras
    }
    
    var title: String {
        switch self {
        case .size: return SaladItemName.Size.rawValue
        case .lettuce: return SaladItemName.Lettuce.rawValue
        case .vegetable: return SaladItemName.Vegetables.rawValue
        case .topping: return SaladItemName.Toppings.rawValue
        case .dressing: return SaladItemName.Dressings.rawValue
        case .extra: return SaladItemName.Extras.rawValue
        }
    }
    
    static func type(for title: String) -> SaladItemType? {
        switch title {
        case SaladItemName.Size.rawValue: return SaladItemType.size
        case SaladItemName.Lettuce.rawValue: return SaladItemType.lettuce
        case SaladItemName.Vegetables.rawValue: return SaladItemType.vegetable
        case SaladItemName.Toppings.rawValue: return SaladItemType.topping
        case SaladItemName.Dressings.rawValue: return SaladItemType.dressing
        case SaladItemName.Extras.rawValue: return SaladItemType.extra
        default: return nil
        }
    }
    
    static var all: [SaladItemType] {
        return [.size, .lettuce, .vegetable, .topping, .dressing, .extra]
    }
}
