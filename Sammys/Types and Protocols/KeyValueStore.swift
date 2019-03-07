//
//  KeyValueStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/6/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol KeyValueStoreKey {
    var rawValue: String { get }
}

protocol KeyValueStore {
    func set<Element>(_ value: [Element], forKey key: KeyValueStoreKey)
    
    func array<Element>(of elementType: Element.Type, forKey key: KeyValueStoreKey) -> [Element]?
}
