//
//  AnyPurchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct AnyPurchasable: Purchasable {
	let purchasable: Purchasable
	
	var category: PurchasableCategory { return purchasable.category }
	var title: String { return purchasable.title }
	var description: String { return purchasable.description }
	var price: Double { return purchasable.price }
	
	init(_ purchasable: Purchasable) { self.purchasable = purchasable }
}

// MARK: - Encodable
extension AnyPurchasable: Encodable {
	func encode(to encoder: Encoder) throws {
		var cotainer = encoder.singleValueContainer()
		try cotainer.encode(AnyCodableProtocol(purchasable))
	}
}

// MARK: - Decodable
extension AnyPurchasable: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		guard let purchasable =
			(try container.decode(AnyCodableProtocol.self)).base as? Purchasable
			else { throw AnyPurchasableError.cantDecodePurchasable }
		self.purchasable = purchasable
	}
}

// MARK: - Equatable
extension AnyPurchasable: Equatable {
	static func == (lhs: AnyPurchasable, rhs: AnyPurchasable) -> Bool {
		return AnyEquatableProtocol(lhs.purchasable) == AnyEquatableProtocol(rhs.purchasable)
	}
}

// MARK: - Hashable
extension AnyPurchasable: Hashable {
	func hash(into hasher: inout Hasher) {
		AnyHashableProtocol(purchasable).hash(into: &hasher)
	}
}

enum AnyPurchasableError: Error { case cantDecodePurchasable }
