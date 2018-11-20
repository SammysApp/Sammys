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
	let date: Date
	let user: User
	let purchasableQuantities: [PurchasableQuantity]
	let price: Price
	let more: More?
	let status: Status
	
	struct User: Codable {
		let userName: String
		let userID: String?
		
		init(userName: String, userID: String? = nil) {
			self.userName = userName
			self.userID = userID
		}
	}
	
	struct More: Codable {
		let pickupDate: Date?
		let note: String?
	}
	
	struct Status: Codable {
		let isInProgress: Bool
		let isComplete: Bool
		
		init(isInProgress: Bool = false, isComplete: Bool = false) {
			self.isInProgress = isInProgress
			self.isComplete = isComplete
		}
	}
}
