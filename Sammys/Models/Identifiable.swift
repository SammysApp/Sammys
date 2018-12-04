//
//  Identifiable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Identifiable {
	var id: String { get }
}

extension Identifiable where Self: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}
