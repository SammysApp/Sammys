//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents an item ✅ in a particular `Food` type.
protocol Item {
    /// The name of the item.
    var name: String { get }
}
