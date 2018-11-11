//
//  FoodItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CategorizedFoodItems {
	let category: FoodItemCategory
	let items: [FoodItem]
}

protocol FoodItemCategory: ProtocolHashable {
	var rawValue: String { get }
	var name: String { get }
}

extension FoodItemCategory where Self: RawRepresentable, Self.RawValue == String {
	var name: String { return rawValue.capitalizingFirstLetter() }
}
