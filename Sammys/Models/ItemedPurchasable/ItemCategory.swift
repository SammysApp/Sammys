//
//  ItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum ItemCategory: String {
	// MARK: - Itemed Salad
	case sizes, lettuces, vegetables, toppings, dressings, extras
}

extension ItemCategory {
	var name: String { return rawValue.capitalizingFirstLetter() }
}

// MARK: - Hashable
extension ItemCategory: Hashable {}

// MARK: - Codable
extension ItemCategory: Codable {}
