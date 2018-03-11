//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A protocol that represents an item ✅ in a particular `Food` type.
protocol Item {
    /// The type of item.
    static var type: ItemType { get }
    /// The name of the item.
    var name: String { get }
}

/// A protocol that represents an `Item` type.
protocol ItemType {
    var title: String { get }
}
