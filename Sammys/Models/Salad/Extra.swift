//
//  Extra.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Extra: ModifiableFoodItem, OptionallyPricedFoodItem {
	static let itemName = SaladFoodItemCategory.extra.rawValue
    let name: String
    let description: String
    let price: Double?
	let modifiers: [Modifier]
}

extension Extra: Hashable {}
