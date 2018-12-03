//
//  SaladItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladItemCategory: String, ItemCategory {
	case sizes, lettuces, vegetables, toppings, dressings, extras
}

// MARK: - Hashable
extension SaladItemCategory: Hashable {}

// MARK: - CaseIterable
extension SaladItemCategory: CaseIterable {}
