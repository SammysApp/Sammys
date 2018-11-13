//
//  ItemedPurchasableBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchasableBuildable {
	static var builder: ItemedPurchasableBuilder { get }
}

protocol ItemedPurchasableBuilder {
	var items: [Item] { get set }
	var modifiers: [AnyHashableProtocol : [Modifier]] { get set }
	mutating func toggle(_ item: Item) throws
	mutating func toggle(_ modifier: Modifier, for item: Item) throws
	mutating func toggleExisting(from itemedPurchasable: ItemedPurchasable) throws
	func build() throws -> ItemedPurchasable
}

extension ItemedPurchasableBuilder {
	mutating func toggle(_ item: Item) throws {
		items = items.map { AnyEquatableProtocol($0) }.contains(AnyEquatableProtocol(item)) ?
			items.filter { AnyEquatableProtocol($0) != AnyEquatableProtocol(item) } :
			items.appending(item)
	}
	
	mutating func toggle(_ modifier: Modifier, for item: Item) throws {
		if let itemModifiers = modifiers[AnyHashableProtocol(item)] {
			modifiers[AnyHashableProtocol(item)] =
				itemModifiers.contains(modifier) ?
				itemModifiers.filter { $0 != modifier } :
				itemModifiers.appending(modifier)
		} else { modifiers[AnyHashableProtocol(item)] = [modifier] }
	}
	
	mutating func toggleExisting(from itemedPurchasable: ItemedPurchasable) throws {}
}
