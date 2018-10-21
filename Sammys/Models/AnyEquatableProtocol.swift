//
//  AnyEquatableProtocol.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ProtocolEquatable {
	func isEqual(to other: ProtocolEquatable) -> Bool
}

extension ProtocolEquatable where Self: Equatable {
	func isEqual(to other: ProtocolEquatable) -> Bool {
		guard let otherSelfObject = other as? Self else { return false }
		return self == otherSelfObject
	}
}

struct AnyEquatableProtocol {
	private let value: ProtocolEquatable
	
	var base: Any { return value }
	
	init(_ value: ProtocolEquatable) {
		self.value = value
	}
}

extension AnyEquatableProtocol: Equatable {
	static func == (lhs: AnyEquatableProtocol, rhs: AnyEquatableProtocol) -> Bool {
		return lhs.value.isEqual(to: rhs.value)
	}
}
