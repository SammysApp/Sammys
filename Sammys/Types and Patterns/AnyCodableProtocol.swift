//
//  AnyCodableProtocol.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum ProtocolCodableType: String, Codable {
	case anypurchasable, salad
	
	var metatype: ProtocolCodable.Type {
		switch self {
		case .anypurchasable: return AnyPurchasable.self
		case .salad: return Salad.self
		}
	}
}

protocol ProtocolCodable: Codable {
	/// A value of `ProtocolCodableType` representing the type that conforms to `ProtocolCodable`.
	///
	/// Implement this static property to conform to `ProtocolCodable`.
	static var codableType: ProtocolCodableType { get }
}

extension ProtocolCodable {
	static var codableType: ProtocolCodableType {
		let selfString = String(describing: Self.self)
		guard let codableType = ProtocolCodableType(rawValue: selfString.lowercased()) else { fatalError("Must add \(selfString) value to `CodableType` enum.") }
		return codableType
	}
}

struct AnyCodableProtocol: Codable {
	private let value: ProtocolCodable
	
	var base: Any { return value }
	
	init(_ value: ProtocolCodable) {
		self.value = value
	}
	
	private enum CodingKeys: CodingKey {
		case codableType, value
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(ProtocolCodableType.self, forKey: .codableType)
		self.value = try type.metatype.init(from: container.superDecoder(forKey: .value))
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type(of: value).codableType, forKey: .codableType)
		try value.encode(to: container.superEncoder(forKey: .value))
	}
}
