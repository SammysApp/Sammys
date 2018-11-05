//
//  FoodItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol FoodItem: Codable {
	static var itemName: String { get }
	var name: String { get }
    var description: String { get }
}

protocol PricedFoodItem: FoodItem {
	var price: Double { get }
}

/// Use in cases where instances can either be priced or be free.
protocol OptionallyPricedFoodItem: FoodItem {
	var price: Double? { get }
}

/// A `FoodItem` that includes modifiers.
protocol ModifiableFoodItem: FoodItem {
	var modifiers: [Modifier] { get }
}

/// Use in cases where instances can either be modifiable or not.
protocol OptionallyModifiableFoodItem: FoodItem {
	var modifiers: [Modifier]? { get }
}

/// A `FoodItem` that does not include modifiers.
protocol NonModifiableFoodItem: FoodItem {}
