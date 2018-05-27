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
            return size?.price != nil ? (size!.price * Double(quantity)).rounded(toPlaces: 2) : 0
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

// MARK: - Item Handling
extension Salad {
    func toggle(_ item: Item) {
        if contains(item) {
            remove(item)
        } else {
            add(item)
        }
    }
    
    func toggle(_ modifier: Modifier, for item: Item) {
        // If salad doesn't have the modifier for the item...
        if !contains(modifier, for: item) {
            // ...first add the item if doesn't have...
            if !contains(item) { add(item) }
            // ...and add modifier.
            add(modifier, for: item)
        }
        // If salad has modifier...
        else {
            // ...remove the modifier.
            remove(modifier, for: item)
            // If the item's modifiers are empty, remove the item from salad.
            if item.modifiers?.isEmpty ?? false { remove(item) }
        }
    }
    
    func contains(_ item: Item) -> Bool {
        return ([lettuce, vegetables, toppings, dressings] as [[Item]])
        .contains  {
            $0.contains { item2 in
                Swift.type(of: item2).type.item(item2, isEqualTo: item)
            }
        }
    }
    
    func contains(_ modifier: Modifier, for item: Item) -> Bool {
        return ([lettuce, vegetables, toppings, dressings] as [[Item]])
            .contains { items in items.contains { item2 in Swift.type(of: item2).type.item(item2, isEqualTo: item) && (item2.modifiers?.contains(modifier) ?? false) } }
    }
    
    func add(_ item: Item) {
        var item = item
        item.clearModifiers()
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return }
        switch itemType {
        case .lettuce: self.lettuce.append(item as! Lettuce)
        case .vegetable: vegetables.append(item as! Vegetable)
        case .topping: toppings.append(item as! Topping)
        case .dressing: dressings.append(item as! Dressing)
        case .extra: extras.append(item as! Extra)
        default: break
        }
    }
    
    func add(_ modifier: Modifier, for item: Item) {
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return }
        switch itemType {
        case .lettuce:
            if let index = index(for: item) {
                self.lettuce[index].modifiers?.append(modifier)
            }
        case .dressing:
            if let index = index(for: item) {
                self.dressings[index].modifiers?.append(modifier)
            }
        case .extra:
            if let index = index(for: item) {
                self.extras[index].modifiers?.append(modifier)
            }
        default: break
        }
    }
    
    func remove(_ item: Item) {
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return }
        switch itemType {
        case .lettuce: self.lettuce.remove(item as! Lettuce)
        case .vegetable: vegetables.remove(item as! Vegetable)
        case .topping: toppings.remove(item as! Topping)
        case .dressing: dressings.remove(item as! Dressing)
        case .extra: extras.remove(item as! Extra)
        default: break
        }
    }
    
    func remove(_ modifier: Modifier, for item: Item) {
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return }
        switch itemType {
        case .lettuce:
            if let index = index(for: item) {
                self.lettuce[index].modifiers?.remove(modifier)
            }
        case .dressing:
            if let index = index(for: item) {
                self.dressings[index].modifiers?.remove(modifier)
            }
        case .extra:
            if let index = index(for: item) {
                self.extras[index].modifiers?.remove(modifier)
            }
        default: break
        }
    }
    
    func index(for item: Item) -> Int? {
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return nil }
        switch itemType {
        case .lettuce: return lettuce.index { itemType.item($0, isEqualTo: item) }
        case .vegetable: return vegetables.index { itemType.item($0, isEqualTo: item) }
        case .topping: return toppings.index { itemType.item($0, isEqualTo: item) }
        case .dressing: return dressings.index { itemType.item($0, isEqualTo: item) }
        case .extra: return extras.index { itemType.item($0, isEqualTo: item) }
        default: return nil
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
    
    func item(_ item1: Item, isEqualTo item2: Item) -> Bool {
        switch (item1, item2) {
        case (let lettuce1 as Lettuce, let lettuce2 as Lettuce):
            return lettuce1 == lettuce2
        case (let vegetable1 as Vegetable, let vegetable2 as Vegetable):
            return vegetable1 == vegetable2
        case (let topping1 as Topping, let topping2 as Topping):
            return topping1 == topping2
        case (let dressing1 as Dressing, let dressing2 as Dressing):
            return dressing1 == dressing2
        default: return false
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
