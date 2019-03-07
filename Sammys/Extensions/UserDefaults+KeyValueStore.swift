//
//  UserDefaults+KeyValueStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/6/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

extension UserDefaults: KeyValueStore {
    func set<Element>(_ value: [Element], forKey key: KeyValueStoreKey) {
        set(value as Any, forKey: key.rawValue)
    }
    
    func array<Element>(of elementType: Element.Type, forKey key: KeyValueStoreKey) -> [Element]? {
        return array(forKey: key.rawValue) as? [Element]
    }
}
