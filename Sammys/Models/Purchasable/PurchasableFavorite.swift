//
//  PurchasableFavorite.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableFavorite: Codable {
	private let anyPurchasable: AnyPurchasable
	
	enum CodingKeys: String, CodingKey {
		case anyPurchasable = "purchasable"
	}
	
	init(_ purchasable: Purchasable) {
		self.anyPurchasable = AnyPurchasable(purchasable)
	}
}

extension PurchasableFavorite {
	var purchasable: Purchasable { return anyPurchasable.purchasable }
}

// MARK: - Hashable
extension PurchasableFavorite: Hashable {}
