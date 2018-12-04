//
//  AnyPurchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum AnyPurchasableError: Error { case cantDecodePurchasableType }

struct AnyPurchasable: Purchasable {
	let purchasable: Purchasable
	
	var category: PurchasableCategory { return purchasable.category }
	var title: String { return purchasable.title }
	var description: String { return purchasable.description }
	var price: Double { return purchasable.price }
	var isTaxSubjected: Bool { return purchasable.isTaxSubjected }
	
	init(_ purchasable: Purchasable) {
		self.purchasable = purchasable
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let codablePurchasable = try container.decode(AnyCodableProtocol.self)
		guard let purchasable = codablePurchasable.base as? Purchasable
			else { throw AnyPurchasableError.cantDecodePurchasableType }
		self.purchasable = purchasable
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(AnyCodableProtocol(purchasable))
	}
}

// MARK: - ProtocolCodable
extension AnyPurchasable: ProtocolCodable {}

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
