//
//  Order.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/23/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Order: Codable {
    let id: String
	let number: String
    let userName: String
    let userID: String?
    let date: Date
    let pickupDate: Date?
    let note: String?
	let purchasableQuantities: [PurchasableQuantity]
}
