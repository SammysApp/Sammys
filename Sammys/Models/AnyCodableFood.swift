//
//  AnyCodableFood.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol CodableFood: Codable where Self: Food {
	static var codableFoodType: CodableFoodType { get }
}

enum CodableFoodType: String, Codable {
	case salad
	
	var metatype: CodableFood.Type {
		switch self {
		case .salad:
			return Salad.self
		}
	}
}

struct AnyCodableFood: Codable {
	private let codableFood: CodableFood
	
	init(_ codableFood: CodableFood) {
		self.codableFood = codableFood
	}
	
	private enum CodingKeys: CodingKey {
		case type, food
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(CodableFoodType.self, forKey: .type)
		self.codableFood = try type.metatype.init(from: container.superDecoder(forKey: .food))
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type(of: codableFood).codableFoodType, forKey: .type)
		try codableFood.encode(to: container.superEncoder(forKey: .food))
	}
}
