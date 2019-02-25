//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Item: Codable {
    typealias ID = UUID
    
    let id: ID
    let name: String
    
    let categoryItemID: UUID?
    let isModifiable: Bool?
}
