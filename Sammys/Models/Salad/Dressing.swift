//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Dressing: ModifiableFoodItem {
	static let itemName = SaladFoodItemCategory.dressing.rawValue
    let name: String
    let description: String
    let modifiers: [Modifier]
}

extension Dressing: Hashable {}
