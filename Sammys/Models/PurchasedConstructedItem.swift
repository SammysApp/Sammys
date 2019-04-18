//
//  PurchasedConstructedItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class PurchasedConstructedItem: Codable {
    typealias ID = UUID
    
    let id: ID
    let quantity: Int
    let name: String?
}
