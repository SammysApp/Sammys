//
//  Size.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents the size 🥣 for a `Salad` instance.
struct Size: Item, Codable, Equatable {
    let name: String
    
    /// The price for the size.
    let price: Double
    
    static func ==(lhs: Size, rhs: Size) -> Bool {
        return lhs.name == rhs.name
    }
}