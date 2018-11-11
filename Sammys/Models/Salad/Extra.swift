//
//  Extra.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Extra: OptionallyModifiableItem, OptionallyPricedItem {
	static let itemName = SaladItemCategory.extra.rawValue
    let name: String
    let description: String
    let price: Double?
	let modifiers: [Modifier]?
}

// MARK: - Hashable
extension Extra: Hashable {}
