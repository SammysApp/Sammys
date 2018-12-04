//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Dressing: ModifiableItem {
	static let category = SaladItemCategory.dressings
	var category: ItemCategory { return Dressing.category }
	
    let name: String
    let description: String
    let modifiers: [Modifier]
	let id: String
}

// MARK: - Hashable
extension Dressing: Hashable {}
