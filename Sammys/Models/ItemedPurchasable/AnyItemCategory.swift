//
//  AnyItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct AnyItemCategory: ItemCategory {
	let itemCategory: ItemCategory
	
	var rawValue: String { return itemCategory.rawValue }
	var name: String { return itemCategory.name }
	
	init(_ itemCategory: ItemCategory) { self.itemCategory = itemCategory }
	init?(rawValue: String) { return nil }
}

// MARK: - Encodable
extension AnyItemCategory: Encodable {
	func encode(to encoder: Encoder) throws {
		var cotainer = encoder.singleValueContainer()
		try cotainer.encode(AnyCodableProtocol(itemCategory))
	}
}

// MARK: - Decodable
extension AnyItemCategory: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let codableProtocol = try container.decode(AnyCodableProtocol.self)
		guard let itemCategory = codableProtocol.base as? ItemCategory
			else { throw AnyItemCategoryError.cantDecodeItemCategory }
		self.itemCategory = itemCategory
	}
}

// MARK: - Equatable
extension AnyItemCategory: Equatable {
	static func == (lhs: AnyItemCategory, rhs: AnyItemCategory) -> Bool {
		return AnyEquatableProtocol(lhs.itemCategory) == AnyEquatableProtocol(rhs.itemCategory)
	}
}

// MARK: - Hashable
extension AnyItemCategory: Hashable {
	func hash(into hasher: inout Hasher) {
		AnyHashableProtocol(itemCategory).hash(into: &hasher)
	}
}

enum AnyItemCategoryError: Error { case cantDecodeItemCategory }
