//
//  PurchasedOrder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class PurchasedOrder: Codable {
    typealias ID = UUID
    
    let id: ID
    let number: Int
    var purchasedDate: Date
    let preparedForDate: Date?
    var note: String?
    let progress: OrderProgress
    let user: User?
}
