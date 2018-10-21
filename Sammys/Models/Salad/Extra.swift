//
//  Extra.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Extra: OptionallyPricedFoodItem, ModifiableFoodItem {
    let name: String
    let description: String
    let price: Double?
	let modifiers: [Modifier]
}

extension Extra: Hashable {}

extension Extra: ArrayBuildable {
	typealias ArrayBuilder = [Extra : [Modifier : Bool]]
	
	static func buildArray(from builder: ArrayBuilder) -> [Extra] {
		let filteredExtras = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredExtras.compactMap { extra in
			guard let modifierKeys = builder[extra]?.filter({ $1 }).keys else { return nil }
			return Extra(name: extra.name, description: extra.description, price: extra.price, modifiers: Array(modifierKeys))
		}
	}
}
