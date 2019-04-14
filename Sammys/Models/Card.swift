//
//  Card.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Card: Codable {
    typealias ID = String
    
    let id: ID
    let name: String
}
