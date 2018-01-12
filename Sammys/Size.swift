//
//  Size.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Size: Item, Codable, Equatable {
    let name: String
    let price: Double
    
    static func ==(lhs: Size, rhs: Size) -> Bool {
        return lhs.name == rhs.name
    }
}
