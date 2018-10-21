//
//  Food.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Food {}

protocol EquatableProtocol {
	func isEqual(to other: EquatableProtocol) -> Bool
	func asEquatable() -> AnyEquatableProtocol
}

extension EquatableProtocol where Self: Equatable {
	func isEqual(to other: EquatableProtocol) -> Bool {
		guard let otherProtocolConfomingObject = other as? Self else { return false }
		return self == otherProtocolConfomingObject
	}
	
	func asEquatable() -> AnyEquatableProtocol {
		return AnyEquatableProtocol(self)
	}
}

struct AnyEquatableProtocol: EquatableProtocol {
	private let equatableProtocol: EquatableProtocol
	
	init(_ equatableProtocol: EquatableProtocol) {
		self.equatableProtocol = equatableProtocol
	}
}

extension AnyEquatableProtocol: Equatable {
	static func == (lhs: AnyEquatableProtocol, rhs: AnyEquatableProtocol) -> Bool {
		return lhs.equatableProtocol.isEqual(to: rhs.equatableProtocol)
	}
}

protocol HashableProtocol: EquatableProtocol {
	func hashProtocol(into hasher: inout Hasher)
}

extension HashableProtocol where Self: Hashable {
	func hashProtocol(into hasher: inout Hasher) {
		hash(into: &hasher)
	}
}

struct AnyHashableProtocol: HashableProtocol {
	private let hashableProtocol: HashableProtocol
	
	init(_ hashableProtocol: HashableProtocol) {
		self.hashableProtocol = hashableProtocol
	}
	
	func hash(into hasher: inout Hasher) {
		hashableProtocol.hashProtocol(into: &hasher)
	}
}

extension AnyHashableProtocol: Hashable {
	static func == (lhs: AnyHashableProtocol, rhs: AnyHashableProtocol) -> Bool {
		return lhs.hashableProtocol.isEqual(to: rhs.hashableProtocol)
	}
}
