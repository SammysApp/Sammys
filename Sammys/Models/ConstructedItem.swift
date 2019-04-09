//
//  ConstructedItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/28/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class ConstructedItem: Codable {
    typealias ID = UUID
    
    let id: ID
    let categoryID: Category.ID
    let name: String?
    let description: String?
    let quantity: Int?
    let totalPrice: Int?
    let isFavorite: Bool
}
