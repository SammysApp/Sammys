//
//  Extra.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Extra: OptionallyModifiableItem, OptionallyPricedItem {
	static let category = SaladItemCategory.extras
	var category: ItemCategory { return Extra.category }
	
    let name: String
    let description: String
    let price: Double?
	let modifiers: [Modifier]?
	let id: String
}

// MARK: - Hashable
extension Extra: Hashable {}
