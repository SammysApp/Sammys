//
//  Lettuce.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Lettuce: Decodable, Equatable {
    let name: String
    let description: String
    
    static func ==(lhs: Lettuce, rhs: Lettuce) -> Bool {
        return lhs.name == rhs.name
    }
}
