//
//  Lettuce.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Lettuce: ModifiableFoodItem {
	let itemName = SaladFoodItem.lettuce.rawValue
    let name: String
    let description: String
    let modifiers: [Modifier]
}

extension Lettuce: Hashable {}
