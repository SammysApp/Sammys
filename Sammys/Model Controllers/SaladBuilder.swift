//
//  SaladBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladBuilderError: Error {
	case noSize, needsModifier
}

private struct SizeBuilder: NonModifiableFoodItemBuilder, SingleFoodItemBuildable {
	typealias FoodItemBuilding = Size
	var builder: Builder = [:]
	
	func build() -> Built? { return Array(builder.filter { $1 }.keys).first }
}

private struct LettuceBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Lettuce
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredLettuce = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredLettuce.compactMap { lettuce in
			guard let modifierKeys = builder[lettuce]?.filter({ $1 }).keys else { return nil }
			return Lettuce(name: lettuce.name, description: lettuce.description, modifiers: Array(modifierKeys))
		}
	}
}

private struct VegetablesBuilder: NonModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Vegetable
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

private struct ToppingsBuilder: NonModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Topping
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

private struct DressingsBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Dressing
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredDressings = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredDressings.compactMap { dressing in
			guard let modifierKeys = builder[dressing]?.filter({ $1 }).keys else { return nil }
			return Dressing(name: dressing.name, description: dressing.description, modifiers: Array(modifierKeys))
		}
	}
}

private struct ExtrasBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Extra
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredExtras = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredExtras.compactMap { extra in
			guard let modifierKeys = builder[extra]?.filter({ $1 }).keys else { return nil }
			return Extra(name: extra.name, description: extra.description, price: extra.price, modifiers: Array(modifierKeys))
		}
	}
}

struct SaladBuilder: FoodBuilder {
	private var sizeBuilder = SizeBuilder()
	private var lettuceBuilder = LettuceBuilder()
	private var vegetablesBuilder = VegetablesBuilder()
	private var toppingsBuilder = ToppingsBuilder()
	private var dressingsBuilder = DressingsBuilder()
	private var extrasBuilder = ExtrasBuilder()
	
	mutating func toggle(_ foodItem: FoodItem, with modifier: Modifier? = nil) throws {
		if let saladFoodItem = SaladFoodItemCategory(rawValue: type(of: foodItem).itemName) {
			switch saladFoodItem {
			case .size: sizeBuilder.toggle(foodItem)
			case .lettuce:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				lettuceBuilder.toggle(foodItem, with: modifier)
			case .vegetable: vegetablesBuilder.toggle(foodItem)
			case .topping: toppingsBuilder.toggle(foodItem)
			case .dressing:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				dressingsBuilder.toggle(foodItem, with: modifier)
			case .extra:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				extrasBuilder.toggle(foodItem, with: modifier)
			}
		}
	}
	
	func build() throws -> Food {
		guard let size = sizeBuilder.build()
			else { throw SaladBuilderError.noSize }
		return Salad(
			size: size,
			lettuce: lettuceBuilder.build(),
			vegetables: vegetablesBuilder.build(),
			toppings: toppingsBuilder.build(),
			dressings: dressingsBuilder.build(),
			extras: extrasBuilder.build()
		)
	}
}
