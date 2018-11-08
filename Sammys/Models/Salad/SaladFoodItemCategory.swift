//
//  SaladFoodItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladFoodItemCategory: String {
	case size, lettuce, vegetable, topping, dressing, extra
}

extension SaladFoodItemCategory: FoodItemCategory {}
extension SaladFoodItemCategory: Hashable {}
extension SaladFoodItemCategory: CaseIterable {}
