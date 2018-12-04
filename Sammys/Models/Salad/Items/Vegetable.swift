//
//  Vegetable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Vegetable: Item {
	static let category: ItemCategory = SaladItemCategory.vegetables
    let name: String
    let description: String
	let id: String
}

// MARK: - Hashable
extension Vegetable: Hashable {}
