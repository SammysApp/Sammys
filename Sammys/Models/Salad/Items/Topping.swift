//
//  Topping.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Topping: OptionallyPricedItem {
	static let category = SaladItemCategory.toppings
	var category: ItemCategory { return Topping.category }
	
    let name: String
    let description: String
    let price: Double?
	let id: String
}

// MARK: - Hashable
extension Topping: Hashable {}
