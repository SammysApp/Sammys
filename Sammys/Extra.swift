//
//  Extra.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents an extra 🧀 in a `Salad` instance.
struct Extra: Item, Codable, Equatable {
    let name: String
    let description: String
    
    /// The price for the extra.
    let price: Double
    
    static func ==(lhs: Extra, rhs: Extra) -> Bool {
        return lhs.name == rhs.name
    }
}
