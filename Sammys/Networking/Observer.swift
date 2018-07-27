//
//  Observer.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

typealias ObserverID = String

protocol Observer {
    var id: ObserverID { get }
    func update<T>(with newValue: T)
}

struct UpdateClosure<S>: Observer {
    let id: ObserverID
    let closure: (S) -> ()
    
    func update<T>(with newValue: T) {
        guard let newValue = newValue as? S else { return }
        closure(newValue)
    }
}

protocol Observable {
    associatedtype T
    var value: T { get set }
    func add(_ observer: Observer)
    func remove(_ observer: Observer)
    func notifyAllObservers(of newValue: T)
}

class Variable<T>: Observable {
    var _value: T! {
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

extension Observer where Self: AnyObject {
    var id: ObserverID { return ObserverID(UInt(bitPattern: ObjectIdentifier(self))) }
}
