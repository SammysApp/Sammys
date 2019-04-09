//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class Item: Codable {
    typealias ID = UUID
    typealias CategoryItemID = UUID
    
    let id: ID
    let categoryItemID: CategoryItemID?
    let name: String
    let price: Int?
    let isModifiable: Bool?
}
