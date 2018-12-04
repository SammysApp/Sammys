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
	private let codablePurchasable: AnyCodableProtocol
	
	enum CodingKeys: String, CodingKey {
		case quantity
		case codablePurchasable = "purchasable"
	}
	
	init(quantity: Int, purchasable: Purchasable) {
		self.quantity = quantity
		self.codablePurchasable = AnyCodableProtocol(purchasable)
	}
}

extension PurchasableQuantity {
	var purchasable: Purchasable { return codablePurchasable.base as! Purchasable }
	var quantitativePrice: Double { return purchasable.price * Double(quantity) }
}
