//
//  OutstandingOrder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/6/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class OutstandingOrder: Codable {
    typealias ID = UUID
    
    let id: ID
    var userID: User.ID?
    var preparedForDate: Date?
    var note: String?
    let totalPrice: Int?
    let taxPrice: Int?
}
