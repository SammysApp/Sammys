//
//  ItemedPurchaseableBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchaseableBuildable {
	static var builder: ItemedPurchaseableBuilder.Type { get }
}

protocol ItemedPurchaseableBuilder {
	mutating func toggle(_ item: Item, with modifier: Modifier?) throws
	mutating func toggleExisting(in itemedPurchaseable: ItemedPurchaseable) throws
	func build() throws -> ItemedPurchaseable
	init()
}

extension ItemedPurchaseableBuilder {
	mutating func toggleExisting(in itemedPurchaseable: ItemedPurchaseable) throws {
		for category in type(of: itemedPurchaseable).allItemCategories {
			// FIXME: Handle modifiers
			try itemedPurchaseable.items(for: category).forEach { try toggle($0, with: nil) }
		}
	}
}
