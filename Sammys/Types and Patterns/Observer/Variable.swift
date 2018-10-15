//
//  Variable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Variable<T>: Observable {
    private var _value: T! {
        didSet { notifyAllObservers(of: value) }
    }
    var value: T {
        get { return _value }
        set { _value = newValue }
    }
    private var observers: [ObserverID : Observer] = [:]
    
    init(observers: [Observer]) { add(observers) }
    convenience init(observers: Observer...) { self.init(observers: observers) }
	
    func add(_ observer: Observer) { observers[observer.id] = observer }
    func remove(_ observer: Observer) { observers.removeValue(forKey: observer.id) }
    
    func add(_ observers: [Observer]) { observers.forEach(add) }
    
    func adding(_ observer: Observer) -> Self {
        add(observer)
        return self
    }
    
    func notifyAllObservers(of newValue: T) {
        observers.forEach { $1.update(with: newValue) }
    }
}
