//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Dressing: Item, Codable, Equatable {
    let name: String
    let description: String
    
    static func ==(lhs: Dressing, rhs: Dressing) -> Bool {
        return lhs.name == rhs.name
    }
}
