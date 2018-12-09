//
//  PurchasableQuantity.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableQuantity: Purchasable {
	let quantity: Int
	private let anyPurchasable: AnyPurchasable
	
	var category: PurchasableCategory { return purchasable.category }
	var title: String { return purchasable.title }
	var description: String { return purchasable.description }
	var price: Double { return purchasable.price }
	
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
}

// MARK: - Hashable
extension PurchasableQuantity: Hashable {}
