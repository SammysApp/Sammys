//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad {
	let size: Size
	let lettuce: [Lettuce]?
    let vegetables: [Vegetable]?
    let toppings: [Topping]?
    let dressings: [Dressing]?
    let extras: [Extra]?
}

// MARK: - Purchasable
extension Salad: Purchasable {
	var title: String { return "\(size.name) Salad" }
	
	var description: String {
		let itemNames = items(for: [.lettuces, .vegetables, .toppings, .dressings, .extras] as [SaladItemCategory]).map { $0.name.lowercased() }
		return "\(size.name) size salad" + (itemNames.isEmpty ? "" : " with \(itemNames.joined(separator: ", "))") + "."
	}
	
	var price: Double {
		// FIXME: Account for priced modifiers.
		return size.price + ([toppings ?? [], extras ?? []] as [[OptionallyPricedItem]])
			.flatMap { $0 }
			.compactMap { $0.price }
			.reduce(0, +)
	}
	
	var isTaxSubjected: Bool { return true }
}

// MARK: - ItemedPurchasable
extension Salad: ItemedPurchasable {
	static var allItemCategories: [ItemCategory] { return SaladItemCategory.allCases }
	
	func items(for itemCategory: ItemCategory) -> [Item] {
		guard let saladItemCategory = itemCategory as? SaladItemCategory
			else { return [] }
		switch saladItemCategory {
		case .sizes: return [size]
		case .lettuces: return lettuce ?? []
		case .vegetables: return vegetables ?? []
		case .toppings: return toppings ?? []
		case .dressings: return dressings ?? []
		case .extras: return extras ?? []
		}
	}
}

// MARK: - Hashable
extension Salad: Hashable {}

// MARK: - ProtocolCodable
extension Salad { static var type = ProtocolCodableType.salad }

private extension Salad {
	func items(for itemCategories: [ItemCategory]) -> [Item] {
		return itemCategories.flatMap { items(for: $0) }
	}
}
