//
//  ItemBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemBuilder {
	associatedtype ItemBuilding: Item & Hashable
}

protocol NonModifiableItemBuilder: ItemBuilder {
	typealias Builder = [ItemBuilding : Bool]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: Item)
}

protocol ModifiableItemBuilder: ItemBuilder {
	typealias Builder = [ItemBuilding : [Modifier : Bool]]
	var builder: Builder { get set }
	mutating func toggle(_ foodItem: Item, with modifier: Modifier)
}

extension NonModifiableItemBuilder {
	mutating func toggle(_ foodItem: Item) {
		guard let foodItemBuilding = foodItem as? ItemBuilding else { return }
		// Negate current value for the food item or set to true.
		builder[foodItemBuilding] = !(builder[foodItemBuilding] ?? false)
	}
}

extension ModifiableItemBuilder {
	mutating func toggle(_ foodItem: Item, with modifier: Modifier) {
		guard let foodItemBuilding = foodItem as? ItemBuilding else { return }
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

protocol SingleItemBuildable: ItemBuilder {
	typealias Built = ItemBuilding
	func build() -> Built?
}

protocol ArrayItemBuildable: ItemBuilder {
	typealias Built = [ItemBuilding]
	func build() -> Built
}
