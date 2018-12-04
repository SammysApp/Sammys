//
//  Size.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Size: PricedItem {
	static let category = SaladItemCategory.sizes
	var category: ItemCategory { return Size.category }
	
    let name: String
    let description: String
    let price: Double
	let id: String
}

// MARK: - Hashable
extension Size: Hashable {}
