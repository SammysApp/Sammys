//
//  Lettuce.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Lettuce: ModifiableItem {
	static let category: ItemCategory = SaladItemCategory.lettuces
    let name: String
    let description: String
    let modifiers: [Modifier]
	let id: String
}

// MARK: - Hashable
extension Lettuce: Hashable {}
