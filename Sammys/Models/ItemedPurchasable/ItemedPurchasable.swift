//
//  ItemedPurchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ItemedPurchasable: Purchasable {
	let category: PurchasableCategory
	let items: [ItemCategory : [Item]]
	let title: String
	let description: String
	let price: Double
}

// MARK: - Hashable
extension ItemedPurchasable: Hashable {}
