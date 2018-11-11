//
//  PurchaseableQuantity.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum PurchaseableQuantityError: Error {
	case cantInitWithPurchaseable
}

struct PurchaseableQuantity: Codable {
	let quantity: Int
	let purchaseable: Purchaseable
	
	enum CodingKeys: String, CodingKey {
		case quantity, purchaseable
	}
	
	init(quantity: Int, purchaseable: Purchaseable) {
		self.quantity = quantity
		self.purchaseable = purchaseable
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.quantity = try container.decode(Int.self, forKey: .quantity)
		guard let purchaseable = try container.decode(AnyCodableProtocol.self, forKey: .purchaseable).base as? Purchaseable
			else { throw PurchaseableQuantityError.cantInitWithPurchaseable }
		self.purchaseable = purchaseable
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(quantity, forKey: .quantity)
		try container.encode(AnyCodableProtocol(purchaseable), forKey: .purchaseable)
	}
}
