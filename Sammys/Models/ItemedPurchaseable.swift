//
//  ItemedPurchaseable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchaseable: Purchaseable {
	static var allItemCategories: [FoodItemCategory] { get }
	var categorizedItems: [CategorizedFoodItems] { get }
	func items(for itemCategory: FoodItemCategory) -> [Item]
}

extension ItemedPurchaseable {
	var categorizedItems: [CategorizedFoodItems] {
		return Self.allItemCategories
			.map { CategorizedFoodItems(category: $0, items: items(for: $0)) }
			.filter { !$0.items.isEmpty }
	}
}
