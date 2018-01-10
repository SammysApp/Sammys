//
//  BagDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class BagDataStore {
    typealias Items = [FoodKey : [Food]]
    
    static let shared = BagDataStore()
    private var _items: Items = [:]
    var items: Items {
        return _items
    }
    
    var itemsTotalPrice: Double? {
        var totalPrice = 0.0
        for (_, foods) in _items {
            foods.forEach { totalPrice += $0.price }
        }
        return totalPrice > 0 ? totalPrice : nil
    }
    
    private init() {
//        if let itemsData = UserDefaults.standard.data(forKey: "items") {
//            do {
//                _items = try JSONDecoder().decode(Items.self, from: itemsData)
//            } catch {
//                print(error)
//            }
//        }
    }
    
    func add(_ food: Food) {
        var foodKey: FoodKey?
        if let _ = food as? Salad {
            foodKey = .salad
        }
        
        if let key = foodKey {
            if _items[key] == nil {
                _items[key] = [food]
            } else {
                _items[key]!.append(food)
            }
        }
        
//        save()
    }
    
    func save() {
        do {
            let itemsData = try JSONEncoder().encode(_items)
            UserDefaults.standard.set(itemsData, forKey: "items")
        } catch {
            print(error)
        }
    }
    
    func clear() {
        _items = [:]
    }
}
