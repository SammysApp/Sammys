//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A protocol that represents an item ✅ in a particular `Food` type.
protocol Item {
    /// The type of item.
    static var type: ItemType { get }
    
    /// The name of the item.
    var name: String { get }
    
    var description: String { get }
    
    var price: Double? { get }
    
    var modifiers: [Modifier]? { get set }
    
    /// The hex color value of the item. Used for UI features.
    var hex: String { get }
}

/// A protocol that represents an `Item` type.
protocol ItemType {
    var title: String { get }
    func item(_ item1: Item, isEqualTo item2: Item) -> Bool
}

extension Item {
    /// The color created using the item's hex value.
    var color: UIColor {
        return hex.isEmpty ? #colorLiteral(red: 0.4499999881, green: 0.9810000062, blue: 0.4740000069, alpha: 1) : UIColor(hex: hex)
    }
    
    mutating func clearModifiers() {
        guard modifiers != nil else { return }
        modifiers = []
    }
}
