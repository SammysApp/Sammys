//
//  PurchasableQuantity.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum PurchasableQuantityError: Error {
	case cantInitWithPurchasable
}

struct PurchasableQuantity: Codable {
	let quantity: Int
	let purchasable: Purchasable
	
	enum CodingKeys: String, CodingKey {
		case quantity, purchasable
	}
	
	init(quantity: Int, purchasable: Purchasable) {
		self.quantity = quantity
		self.purchasable = purchasable
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.quantity = try container.decode(Int.self, forKey: .quantity)
		guard let purchasable = try container.decode(AnyCodableProtocol.self, forKey: .purchasable).base as? Purchasable
			else { throw PurchasableQuantityError.cantInitWithPurchasable }
		self.purchasable = purchasable
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(quantity, forKey: .quantity)
		try container.encode(AnyCodableProtocol(purchasable), forKey: .purchasable)
	}
}

extension PurchasableQuantity {
	var quantitativePrice: Double { return purchasable.price * Double(quantity) }
}
