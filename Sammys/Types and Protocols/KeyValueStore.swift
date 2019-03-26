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
    func set<T>(_ value: T?, forKey key: KeyValueStoreKey)
    
    func value<T>(of type: T.Type, forKey key: KeyValueStoreKey) -> T?
}
