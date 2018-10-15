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

extension Observer where Self: AnyObject {
    var id: ObserverID { return ObserverID(UInt(bitPattern: ObjectIdentifier(self))) }
}
