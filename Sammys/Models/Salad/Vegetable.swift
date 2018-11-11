//
//  Vegetable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Vegetable: Item {
	static let itemName = SaladFoodItemCategory.vegetable.rawValue
    let name: String
    let description: String
}

extension Vegetable: Hashable {}
