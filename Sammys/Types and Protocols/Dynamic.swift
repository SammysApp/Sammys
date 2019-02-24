//
//  Dynamic.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Dynamic<Value> {
    typealias Listener = (Value) -> Void
    
    private var listener: Listener?
    
    var value: Value {
        didSet { listener?(value) }
    }
    
    init(_ value: Value) {
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

extension Dynamic: Equatable where Value: Equatable {
    static func == (lhs: Dynamic<Value>, rhs: Dynamic<Value>) -> Bool {
        return lhs.value == rhs.value
    }
}
