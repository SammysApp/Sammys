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

protocol FoodItemBuilder {
	associatedtype FoodItemBuilding: FoodItem & Hashable
}

protocol NonModifiableFoodItemBuilder: FoodItemBuilder {
	typealias Builder = [FoodItemBuilding : Bool]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: FoodItem)
}

protocol ModifiableFoodItemBuilder: FoodItemBuilder {
	typealias Builder = [FoodItemBuilding : [Modifier : Bool]]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: FoodItem, with modifier: Modifier)
}

extension NonModifiableFoodItemBuilder {
	mutating func toggle(_ foodItem: FoodItem) {
		guard let foodItemBuilding = foodItem as? FoodItemBuilding else { return }
		// Negate current value for the food item or set to true.
		builder[foodItemBuilding] = !(builder[foodItemBuilding] ?? false)
	}
}

extension ModifiableFoodItemBuilder {
	mutating func toggle(_ foodItem: FoodItem, with modifier: Modifier) {
		guard let foodItemBuilding = foodItem as? FoodItemBuilding else { return }
		// If a modifier dictionary is present for the food item...
		if builder[foodItemBuilding] != nil {
			// ...negate the current value for the modifier or set to true.
			builder[foodItemBuilding]![modifier] = !(builder[foodItemBuilding]![modifier] ?? false)
		} else {
			// Otherwise initialize a modifier dictionary.
			builder[foodItemBuilding] = [modifier: true]
		}
	}
}

protocol SingleFoodItemBuildable: FoodItemBuilder {
	typealias Built = FoodItemBuilding
	func build() -> Built?
}

protocol ArrayFoodItemBuildable: FoodItemBuilder {
	typealias Built = [FoodItemBuilding]
	func build() -> Built
}

struct SizeBuilder: NonModifiableFoodItemBuilder, SingleFoodItemBuildable {
	typealias FoodItemBuilding = Size
	var builder: Builder = [:]
	
	func build() -> Built? { return Array(builder.filter { $1 }.keys).first }
}

struct LettuceBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
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

struct VegetablesBuilder: NonModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Vegetable
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

struct ToppingsBuilder: NonModifiableFoodItemBuilder, ArrayFoodItemBuildable {
	typealias FoodItemBuilding = Topping
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

struct DressingsBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
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

struct ExtrasBuilder: ModifiableFoodItemBuilder, ArrayFoodItemBuildable {
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

struct SaladBuilder {
	private var sizeBuilder = SizeBuilder()
	private var lettuceBuilder = LettuceBuilder()
	private var vegetablesBuilder = VegetablesBuilder()
	private var toppingsBuilder = ToppingsBuilder()
	private var dressingsBuilder = DressingsBuilder()
	private var extrasBuilder = ExtrasBuilder()
	
	func build() throws -> Salad {
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
	
	mutating func toggle(_ foodItem: FoodItem, with modifier: Modifier? = nil) throws {
		if let saladFoodItem = SaladFoodItem(rawValue: type(of: foodItem).itemName) {
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
}
