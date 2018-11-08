//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad: Food {
	let size: Size
	let lettuce: [Lettuce]
    let vegetables: [Vegetable]
    let toppings: [Topping]
    let dressings: [Dressing]
    let extras: [Extra]
}

// MARK: - Purchaseable
extension Salad {
	var title: String {
		return "\(size.name) Salad"
	}
	
	var description: String {
		let itemNames = items(for: [.lettuce, .vegetable, .topping, .dressing, .extra] as [SaladFoodItemCategory]).map { $0.name.lowercased() }
		return "\(size.name) size salad" + (itemNames.isEmpty ? "" : " with \(itemNames.joined(separator: ", "))") + "."
	}
	
	var price: Double {
		return size.price + ([toppings, extras] as [[OptionallyPricedFoodItem]])
			.flatMap { $0 }
			.compactMap { $0.price }
			.reduce(0, +)
	}
}

// MARK: - Food
extension Salad {
	var allItemCategories: [FoodItemCategory] {
		return SaladFoodItemCategory.allCases
	}
	
	func items(for itemCategory: FoodItemCategory) -> [FoodItem] {
		guard let saladItemCategory = itemCategory as? SaladFoodItemCategory
			else { return [] }
		switch saladItemCategory {
		case .size: return [size]
		case .lettuce: return lettuce
		case .vegetable: return vegetables
		case .topping: return toppings
		case .dressing: return dressings
		case .extra: return extras
		}
	}
}

// MARK: - ProtocolCodable
extension Salad { static var type = ProtocolCodableType.salad }
extension Salad: Hashable {}

private extension Salad {
	func items(for itemCategories: [FoodItemCategory]) -> [FoodItem] {
		return itemCategories.flatMap { items(for: $0) }
	}
}
