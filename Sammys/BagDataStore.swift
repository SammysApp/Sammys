//
//  BagDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class BagDataStore {
    static let shared = BagDataStore()
    var items: [FoodKey : [Food]] = [:]
    
    private init() {}
    
    func add(_ food: Food) {
        var foodKey: FoodKey?
        if let _ = food as? Salad {
            foodKey = .salad
        }
        
        if let key = foodKey {
            if items[key] == nil {
                items[key] = [food]
            } else {
                items[key]!.append(food)
            }
        }
    }
}
