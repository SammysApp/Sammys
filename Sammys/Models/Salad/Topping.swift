//
//  Topping.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Topping: OptionallyPricedItem {
	static let itemName = SaladFoodItemCategory.topping.rawValue
    let name: String
    let description: String
    let price: Double?
}

extension Topping: Hashable {}
