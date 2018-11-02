//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad: Food {
	let size: Size
	let lettuce: [Lettuce]
    let vegetables: [Vegetable]
    let toppings: [Topping]
    let dressings: [Dressing]
    let extras: [Extra]
}

extension Salad {
	var price: Double {
		return size.price + ([toppings, extras] as [[OptionallyPricedFoodItem]])
			.flatMap { $0 }
			.compactMap { $0.price }
			.reduce(0, +)
	}
}

extension Salad { static var type = ProtocolCodableType.salad }
extension Salad: Hashable {}

enum SaladFoodItemCategory: String, CaseIterable, FoodItemCategory {
	case size, lettuce, vegetable, topping, dressing, extra
}

extension SaladFoodItemCategory: Hashable {}
