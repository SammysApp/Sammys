//
//  Food.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Food: Purchaseable {
	static var allItemCategories: [FoodItemCategory] { get }
	static var itemsDataFetcher: FoodItemsDataFetcher.Type { get }
	static var builder: FoodBuilder.Type { get }
	var categorizedItems: [CategorizedFoodItems] { get }
	func items(for itemCategory: FoodItemCategory) -> [FoodItem]
}

extension Food {
	var categorizedItems: [CategorizedFoodItems] {
		return Self.allItemCategories
			.map { CategorizedFoodItems(category: $0, items: items(for: $0)) }
			.filter { !$0.items.isEmpty }
	}
}
