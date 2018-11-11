//
//  SaladItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladItemCategory: String, ItemCategory {
	case size, lettuce, vegetable, topping, dressing, extra
}

// MARK: - Hashable
extension SaladItemCategory: Hashable {}

// MARK: - CaseIterable
extension SaladItemCategory: CaseIterable {}
