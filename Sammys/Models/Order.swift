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
	let payment: Payment?
	let more: More?
	let status: Status
	
	init(
		id: String = UUID().uuidString,
		number: String,
		date: Date = Date(),
		user: User,
		purchasableQuantities: [PurchasableQuantity],
		price: Price,
		payment: Payment? = nil,
		more: More? = nil,
		status: Status = Status()
	) {
		self.id = id
		self.number = number
		self.date = date
		self.user = user
		self.purchasableQuantities = purchasableQuantities
		self.price = price
		self.payment = payment
		self.more = more
		self.status = status
	}
	
	struct User: Codable {
		let userName: String
		let userID: String
		
		init(userName: String, userID: String) {
			self.userName = userName
			self.userID = userID
		}
	}
	
	struct Price: Codable {
		let tax: Double?
		let discount: Double?
		let total: Double
		
		init(taxPrice: Double? = nil, discount: Double? = nil, totalPrice: Double) {
			self.tax = taxPrice
			self.discount = discount
			self.total = totalPrice
		}
	}
	
	struct Payment: Codable {
		let id: String
		let service: PaymentService
		let method: Method
		
		struct Method: Codable {
			let id: String
			let name: String
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

extension Order {
	var description: String {
		guard let firstPurchasable = purchasableQuantities.first?.purchasable
			else { return "" }
		let othersQuantity = purchasableQuantities.count - 1
		return othersQuantity > 0 ?
			firstPurchasable.title + " and \(othersQuantity) more items." :
			firstPurchasable.title
	}
}
