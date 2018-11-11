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

private struct SizeBuilder: NonModifiableItemBuilder, SingleItemBuildable {
	typealias ItemBuilding = Size
	var builder: Builder = [:]
	
	func build() -> Built? { return Array(builder.filter { $1 }.keys).first }
}

private struct LettuceBuilder: ModifiableItemBuilder, ItemArrayBuildable {
	typealias ItemBuilding = Lettuce
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredLettuce = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredLettuce.compactMap { lettuce in
			guard let modifierKeys = builder[lettuce]?.filter({ $1 }).keys else { return nil }
			return Lettuce(name: lettuce.name, description: lettuce.description, modifiers: Array(modifierKeys))
		}
	}
}

private struct VegetablesBuilder: NonModifiableItemBuilder, ItemArrayBuildable {
	typealias ItemBuilding = Vegetable
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

private struct ToppingsBuilder: NonModifiableItemBuilder, ItemArrayBuildable {
	typealias ItemBuilding = Topping
	var builder: Builder = [:]
	
	func build() -> Built { return Array(builder.filter { $1 }.keys) }
}

private struct DressingsBuilder: ModifiableItemBuilder, ItemArrayBuildable {
	typealias ItemBuilding = Dressing
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredDressings = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredDressings.compactMap { dressing in
			guard let modifierKeys = builder[dressing]?.filter({ $1 }).keys else { return nil }
			return Dressing(name: dressing.name, description: dressing.description, modifiers: Array(modifierKeys))
		}
	}
}

private struct ExtrasBuilder: ModifiableItemBuilder, ItemArrayBuildable {
	typealias ItemBuilding = Extra
	var builder: Builder = [:]
	
	func build() -> Built {
		let filteredExtras = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredExtras.compactMap { extra in
			guard let modifierKeys = builder[extra]?.filter({ $1 }).keys else { return nil }
			return Extra(name: extra.name, description: extra.description, price: extra.price, modifiers: Array(modifierKeys))
		}
	}
}

struct SaladBuilder: ItemedPurchaseableBuilder {
	private var sizeBuilder = SizeBuilder()
	private var lettuceBuilder = LettuceBuilder()
	private var vegetablesBuilder = VegetablesBuilder()
	private var toppingsBuilder = ToppingsBuilder()
	private var dressingsBuilder = DressingsBuilder()
	private var extrasBuilder = ExtrasBuilder()
	
	mutating func toggle(_ item: Item, with modifier: Modifier? = nil) throws {
		if let saladItem = SaladItemCategory(rawValue: type(of: item).category.rawValue) {
			switch saladItem {
			case .size: sizeBuilder.toggle(item)
			case .lettuce:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				lettuceBuilder.toggle(item, with: modifier)
			case .vegetable: vegetablesBuilder.toggle(item)
			case .topping: toppingsBuilder.toggle(item)
			case .dressing:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				dressingsBuilder.toggle(item, with: modifier)
			case .extra:
				guard let modifier = modifier else { throw SaladBuilderError.needsModifier }
				extrasBuilder.toggle(item, with: modifier)
			}
		}
	}
	
	func build() throws -> ItemedPurchaseable {
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

extension Salad: ItemedPurchaseableBuildable {
	static var builder: ItemedPurchaseableBuilder.Type { return SaladBuilder.self }
}
