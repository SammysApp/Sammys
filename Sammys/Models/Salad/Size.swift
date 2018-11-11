//
//  Size.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Size: PricedItem {
	static let category: ItemCategory = SaladItemCategory.size
    let name: String
    let description: String
    let price: Double
}

// MARK: - Hashable
extension Size: Hashable {}
