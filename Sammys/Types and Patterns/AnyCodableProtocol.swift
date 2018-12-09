//
//  AnyCodableProtocol.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ProtocolCodable: Codable {
	
}

struct AnyCodableProtocol: Codable {
	let base: ProtocolCodable
	
	init(_ base: ProtocolCodable) {
		self.base = base
	}
	
	private enum CodingKeys: String, CodingKey {
		case type, value
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(ProtocolCodableType.self, forKey: .type)
		self.base = try type.metatype.init(from: container.superDecoder(forKey: .value))
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type(of: base).codableType, forKey: .type)
		try base.encode(to: container.superEncoder(forKey: .value))
	}
}
