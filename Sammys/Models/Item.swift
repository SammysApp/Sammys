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
    
    /// The hex color value of the item. Used for UI features.
    var hex: String { get }
}

/// A protocol that represents an `Item` type.
protocol ItemType {
    var title: String { get }
}

extension Item {
    /// The color created using the item's hex value.
    var color: UIColor {
        return hex.isEmpty ? .flora : UIColor(hex: hex)
    }
}
