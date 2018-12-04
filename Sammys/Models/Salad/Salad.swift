//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad: Codable {
	static let category = PurchasableCategory.salad
	
	let size: Size
	let lettuces: [Lettuce]
    let vegetables: [Vegetable]
    let toppings: [Topping]
    let dressings: [Dressing]
    let extras: [Extra]
	
	init(
		size: Size,
		lettuces: [Lettuce],
		vegetables: [Vegetable],
		toppings: [Topping],
		dressings: [Dressing],
		extras: [Extra]
	) {
		self.size = size
		self.lettuces = lettuces
		self.vegetables = vegetables
		self.toppings = toppings
		self.dressings = dressings
		self.extras = extras
	}
	
	init(from decoder: Decoder) throws {
		let containter = try decoder.container(keyedBy: CodingKeys.self)
		self.size =
			try containter.decode(Size.self, forKey: .size)
		self.lettuces = try containter.decodeIfPresent([Lettuce].self, forKey: .lettuces) ?? []
		self.vegetables = try containter.decodeIfPresent([Vegetable].self, forKey: .vegetables) ?? []
		self.toppings = try containter.decodeIfPresent([Topping].self, forKey: .toppings) ?? []
		self.dressings = try containter.decodeIfPresent([Dressing].self, forKey: .dressings) ?? []
		self.extras = try containter.decodeIfPresent([Extra].self, forKey: .extras) ?? []
	}
}

// MARK: - Purchasable
extension Salad: Purchasable {
	var category: PurchasableCategory { return Salad.category }
	
	var title: String { return "\(size.name) Salad" }
	
	var description: String {
		let itemNames = items(for: [.lettuces, .vegetables, .toppings, .dressings, .extras] as [SaladItemCategory]).map { $0.name.lowercased() }
		return "\(size.name) size salad" + (itemNames.isEmpty ? "" : " with \(itemNames.joined(separator: ", "))") + "."
	}
	
	var price: Double {
		// FIXME: Account for priced modifiers.
		return size.price + ([toppings, extras] as [[OptionallyPricedItem]])
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
		case .lettuces: return lettuces
		case .vegetables: return vegetables
		case .toppings: return toppings
		case .dressings: return dressings
		case .extras: return extras
		}
	}
}

// MARK: - ProtocolCodable
extension Salad: ProtocolCodable {}

// MARK: - Hashable
extension Salad: Hashable {}

private extension Salad {
	func items(for itemCategories: [ItemCategory]) -> [Item] {
		return itemCategories.flatMap { items(for: $0) }
	}
}
