//
//  Dynamic.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Dynamic<T> {
	typealias Listener = (T) -> Void
    
	private var listener: Listener?
	
	var value: T { didSet { listener?(value) } }
	
	init(_ value: T) {
		self.value = value
	}
	
	func bind(_ listener: @escaping Listener) {
		self.listener = listener
	}
	
	func bindAndRun(_ listener: @escaping Listener) {
		self.listener = listener
		listener(value)
	}
}

extension Dynamic: Equatable where T: Equatable {
	static func == (lhs: Dynamic<T>, rhs: Dynamic<T>) -> Bool {
		return lhs.value == rhs.value
	}
}
