//
//  Observable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Observable {
    associatedtype T
    var value: T { get set }
    func add(_ observer: Observer)
    func remove(_ observer: Observer)
    func notifyAllObservers(of newValue: T)
}
