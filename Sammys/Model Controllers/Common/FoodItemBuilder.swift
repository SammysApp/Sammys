//
//  FoodItemBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol FoodItemBuilder {
	associatedtype FoodItemBuilding: Item & Hashable
}

protocol NonModifiableFoodItemBuilder: FoodItemBuilder {
	typealias Builder = [FoodItemBuilding : Bool]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: Item)
}

protocol ModifiableFoodItemBuilder: FoodItemBuilder {
	typealias Builder = [FoodItemBuilding : [Modifier : Bool]]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: Item, with modifier: Modifier)
}

extension NonModifiableFoodItemBuilder {
	mutating func toggle(_ foodItem: Item) {
		guard let foodItemBuilding = foodItem as? FoodItemBuilding else { return }
		// Negate current value for the food item or set to true.
		builder[foodItemBuilding] = !(builder[foodItemBuilding] ?? false)
	}
}

extension ModifiableFoodItemBuilder {
	mutating func toggle(_ foodItem: Item, with modifier: Modifier) {
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
