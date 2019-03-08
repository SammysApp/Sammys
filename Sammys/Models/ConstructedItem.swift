//
//  ConstructedItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/28/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ConstructedItem: Codable {
    typealias ID = UUID
    
    let id: ID
    let categoryID: Category.ID
    let isFavorite: Bool
    
    let totalPrice: Int?
    let quantity: Int?
}
