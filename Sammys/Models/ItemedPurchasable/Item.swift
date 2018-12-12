//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Item {
	let name: String
    let description: String
	let modifiers: [Modifier]?
	let price: Double?
	let id: String
}

// MARK: - Identifiable
extension Item: Identifiable {}

// MARK: - Equatable
extension Item: Equatable {
	static func == (lhs: Item, rhs: Item) -> Bool {
		return lhs.id == rhs.id && lhs.modifiers == rhs.modifiers
	}
}

// MARK: - Hashable
extension Item: Hashable {}

// MARK: - Codable
extension Item: Codable {}
