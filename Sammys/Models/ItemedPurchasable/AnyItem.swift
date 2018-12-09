//
//  AnyItem.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct AnyItem: Item {
	let item: Item
	
	var category: ItemCategory { return item.category }
	var name: String { return item.name }
	var description: String { return item.description }
	var id: String { return item.id }
	
	init(_ item: Item) {
		self.item = item
	}
}

// MARK: - Encodable
extension AnyItem: Encodable {
	func encode(to encoder: Encoder) throws {
		var cotainer = encoder.singleValueContainer()
		try cotainer.encode(AnyCodableProtocol(item))
	}
}

// MARK: - Decodable
extension AnyItem: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let codableProtocol = try container.decode(AnyCodableProtocol.self)
		guard let item = codableProtocol.base as? Item
			else { throw AnyItemError.cantDecodeItem }
		self.item = item
	}
}

// MARK: - Equatable
extension AnyItem: Equatable {
	static func == (lhs: AnyItem, rhs: AnyItem) -> Bool {
		return AnyEquatableProtocol(lhs.item) == AnyEquatableProtocol(rhs.item)
	}
}

// MARK: - Hashable
extension AnyItem: Hashable {
	func hash(into hasher: inout Hasher) {
		AnyHashableProtocol(item).hash(into: &hasher)
	}
}

enum AnyItemError: Error { case cantDecodeItem }
