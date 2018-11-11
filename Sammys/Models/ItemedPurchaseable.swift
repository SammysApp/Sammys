//
//  ItemedPurchaseable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchaseable: Purchaseable {
	static var allItemCategories: [ItemCategory] { get }
	var categorizedItems: [CategorizedItems] { get }
	func items(for itemCategory: ItemCategory) -> [Item]
}

extension ItemedPurchaseable {
	var categorizedItems: [CategorizedItems] {
		return Self.allItemCategories
			.map { CategorizedItems(category: $0, items: items(for: $0)) }
			.filter { !$0.items.isEmpty }
	}
}
