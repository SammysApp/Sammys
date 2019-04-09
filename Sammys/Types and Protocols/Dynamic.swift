//
//  Dynamic.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Dynamic<Value> {
    typealias ListenerID = UUID
    typealias Listener = (Value) -> Void
    
    private var listeners = [ListenerID: Listener]()
    
    var value: Value {
        didSet { runAll() }
    }
    
    init(_ value: Value) {
        self.value = value
    }
    
    private func runAll() { listeners.values.forEach { $0(value) } }
    
    @discardableResult
    func bind(id: ListenerID = .init(), _ listener: @escaping Listener) -> ListenerID {
        listeners[id] = listener
        return id
    }
    
    @discardableResult
    func bindAndRun(id: ListenerID = .init(), _ listener: @escaping Listener) -> ListenerID {
        listeners[id] = listener
        runAll()
        return id
    }
    
    func unbind(_ id: ListenerID) { listeners[id] = nil }
    
    func unbindAll() { listeners = [:] }
}

extension Dynamic: Equatable where Value: Equatable {
    static func == (lhs: Dynamic<Value>, rhs: Dynamic<Value>) -> Bool {
        return lhs.value == rhs.value
    }
}
