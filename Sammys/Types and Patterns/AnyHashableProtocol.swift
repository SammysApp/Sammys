//
//  AnyHashableProtocol.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ProtocolHashable: ProtocolEquatable {
	func hashProtocol(into hasher: inout Hasher)
}

extension ProtocolHashable where Self: Hashable {
	func hashProtocol(into hasher: inout Hasher) {
		hash(into: &hasher)
	}
}

struct AnyHashableProtocol {
	private let value: ProtocolHashable
	
	var base: Any { return value }
	
	init(_ value: ProtocolHashable) {
		self.value = value
	}
}

extension AnyHashableProtocol: Hashable {
	static func == (lhs: AnyHashableProtocol, rhs: AnyHashableProtocol) -> Bool {
		return lhs.value.isEqual(to: rhs.value)
	}
	
	func hash(into hasher: inout Hasher) {
		value.hashProtocol(into: &hasher)
	}
}
