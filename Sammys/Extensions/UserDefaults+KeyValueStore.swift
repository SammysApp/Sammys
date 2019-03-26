//
//  UserDefaults+KeyValueStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/6/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

extension UserDefaults: KeyValueStore {
    func set<T>(_ value: T?, forKey key: KeyValueStoreKey) {
        self.set(value as Any, forKey: key.rawValue)
    }
    
    func value<T>(of type: T.Type, forKey key: KeyValueStoreKey) -> T? {
        return self.object(forKey: key.rawValue) as? T
    }
}
