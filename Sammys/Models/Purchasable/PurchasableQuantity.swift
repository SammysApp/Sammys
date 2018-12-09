//
//  PurchasableQuantity.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableQuantity: Codable {
	let quantity: Int
	private let anyPurchasable: AnyPurchasable
	
	enum CodingKeys: String, CodingKey {
		case quantity
		case anyPurchasable = "purchasable"
	}
	
	init(quantity: Int, purchasable: Purchasable) {
		self.quantity = quantity
		self.anyPurchasable = AnyPurchasable(purchasable)
	}
}

extension PurchasableQuantity {
	var purchasable: Purchasable { return anyPurchasable.purchasable }
	var quantitativePrice: Double { return purchasable.price * Double(quantity) }
}
