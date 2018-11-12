//
//  ItemedPurchasableBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchasableBuildable {
	static var builder: ItemedPurchasableBuilder.Type { get }
}

protocol ItemedPurchasableBuilder {
	mutating func toggle(_ item: Item, with modifier: Modifier?) throws
	mutating func toggleExisting(in itemedPurchasable: ItemedPurchasable) throws
	func build() throws -> ItemedPurchasable
	init()
}

extension ItemedPurchasableBuilder {
	mutating func toggleExisting(in itemedPurchasable: ItemedPurchasable) throws {
		for category in type(of: itemedPurchasable).allItemCategories {
			// FIXME: Handle modifiers
			try itemedPurchasable.items(for: category).forEach { try toggle($0, with: nil) }
		}
	}
}
