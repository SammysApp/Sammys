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
    
    // FIXME: Put in own model like "SaladOrder"
    /// The quantity of salads to buy. Determines `price` value. Default is `1`.
    var quantity = 1
    
    var userTitle: String?
    
    /// Returns title for salad.
    var title: String {
        return "\(size!.name) Salad"
    }
    
    var itemsCopy: Food {
        return Salad(withItemsFrom: self)
    }
    
    init() {}
    
    init(withItemsFrom otherSalad: Salad) {
        self.size = otherSalad.size
        self.lettuce = otherSalad.lettuce
        self.vegetables = otherSalad.vegetables
        self.toppings = otherSalad.toppings
        self.dressings = otherSalad.dressings
        self.extras = otherSalad.extras
    }
}

extension Salad {
    /// Returns product of the salad's base price and `quantity`. If `size` is `nil` returns `0`.
    var price: Double {
        get {
            return basePrice * Double(quantity).rounded(toPlaces: 2)
        }
    }
    
    private var basePrice: Double {
        guard var price = size?.price else { return 0 }
        if let choppedPrice = choppedPrice { price += choppedPrice }
        return price + itemsPrice
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
            if item is Dressing && dressings.count == 1 {
                dressings = []
            }
            if item is Extra {
                if let index = extras.firstIndex(where: { $0.modifiers != nil }) {
                    extras[index].modifiers = []
                }
            }
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
            if itemModifiersIsEmpty(item) {
                remove(item)
            }
        }
    }
    
    func contains(_ item: Item) -> Bool {
        guard let itemType = Swift.type(of: item).type as? SaladItemType else { return false }
        if itemType == .size { return size == (item as! Size) }
        return ([lettuce, vegetables, toppings, dressings, extras] as [[Item]])
        .contains  {
            $0.contains { item2 in
                Swift.type(of: item2).type.item(item2, isEqualTo: item)
            }
        }
    }
    
    func contains(_ modifier: Modifier, for item: Item) -> Bool {
        return ([lettuce, vegetables, toppings, dressings, extras] as [[Item]])
            .contains { items in items.contains { item2 in Swift.type(of: item2).type.item(item2, isEqualTo: item) && (item2.modifiers?.contains(modifier) ?? false) } }
    }
    
    private func add(_ item: Item) {
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
    
    private func add(_ modifier: Modifier, for item: Item) {
        guard let itemType = Swift.type(of: item).type as? SaladItemType,
            let index = index(for: item) else { return }
        switch itemType {
        case .lettuce: self.lettuce[index].modifiers?.append(modifier)
        case .dressing: dressings[index].modifiers?.append(modifier)
        case .extra: extras[index].modifiers?.append(modifier)
        default: break
        }
    }
    
    private func remove(_ item: Item) {
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
    
    private func remove(_ modifier: Modifier, for item: Item) {
        guard let itemType = Swift.type(of: item).type as? SaladItemType,
            let index = index(for: item) else { return }
        switch itemType {
        case .lettuce: self.lettuce[index].modifiers?.remove(modifier)
        case .dressing: dressings[index].modifiers?.remove(modifier)
        case .extra: extras[index].modifiers?.remove(modifier)
        default: break
        }
    }
    
    private func index(for item: Item) -> Int? {
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
    
    private func itemModifiersIsEmpty(_ item: Item) -> Bool {
        guard let itemType = Swift.type(of: item).type as? SaladItemType,
            let index = index(for: item) else { return false }
        switch itemType {
        case .lettuce: return self.lettuce[index].modifiers?.isEmpty ?? true
        case .dressing: return dressings[index].modifiers?.isEmpty ?? true
        case .extra: return extras[index].modifiers?.isEmpty ?? true
        default: return false
        }
    }
    
    /// One time charge for chopped lettuce.
    private var choppedPrice: Double? {
        for lettuce in lettuce {
            if let price = lettuce.modifiers?.first(where: { $0.title == "Chopped" })?.price {
                return price
            }
        }
        return nil
    }
    
    private var itemsPrice: Double {
        return ([lettuce, vegetables, toppings, dressings, extras] as [[Item]])
            .reduce(0) { itemsSum, items in
                itemsSum + items.reduce(0) { itemSum, item in
                    itemSum + (item.price ?? 0) + modifiersPrice(for: item)
                }
            }
    }
    
    private func modifiersPrice(for item: Item) -> Double {
        return item.modifiers?.reduce(0) { $0 + ($1.title != "Chopped" ? ($1.price ?? 0) : 0) } ?? 0
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
        case (let extra1 as Extra, let extra2 as Extra):
            return extra1 == extra2
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
