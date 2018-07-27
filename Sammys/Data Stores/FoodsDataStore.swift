//
//  FoodsDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A singleton type that stores 📦 all available foods 🍎.
class FoodsDataStore {
    /// The shared single instance.
    static let shared = FoodsDataStore()
    
    /// The available foods represented as a `FoodsData` object.
    var foodsData: FoodsData?
    
    func setFoods(completed: ((_ data: FoodsData) -> Void)? = nil) {
        DataAPIManager.getFoods()
            .get { self.foodsData = $0; completed?($0) }
            .catch { print($0) }
    }
}
