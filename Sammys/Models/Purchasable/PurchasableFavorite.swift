//
//  PurchasableFavorite.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableFavorite: Purchasable {
	private let userTitle: String?
	private let anyPurchasable: AnyPurchasable
	
	var category: PurchasableCategory { return purchasable.category }
	var title: String { return userTitle ?? purchasable.title }
	var description: String { return purchasable.description }
	var price: Double { return purchasable.price }
	
	init(title: String, purchasable: Purchasable) {
		self.userTitle = title
		self.anyPurchasable = AnyPurchasable(purchasable)
	}
}

extension PurchasableFavorite {
	var purchasable: Purchasable { return anyPurchasable.purchasable }
}

extension PurchasableFavorite {
	enum CodingKeys: String, CodingKey {
		case userTitle = "title"
		case anyPurchasable = "purchasable"
	}
}

// MARK: - Hashable
extension PurchasableFavorite: Hashable {}
