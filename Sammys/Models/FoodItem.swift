//
//  FoodItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol FoodItem: Codable {
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

protocol ModifiableFoodItem: FoodItem {
	var modifiers: [Modifier] { get }
}

protocol ArrayBuildable where Self: FoodItem {
	associatedtype ArrayBuilder
	static func buildArray(from builder: ArrayBuilder) -> [Self]
}
