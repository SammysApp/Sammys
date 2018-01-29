//
//  BagDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class BagDataStore {
    typealias Foods = [FoodType: [Food]]
    private typealias SavedFoods = [FoodType : [AnyFood]]
    
    static let shared = BagDataStore()
    private var _foods: Foods = [:]
    var foods: Foods {
        return _foods
    }
    private var savedItems: SavedFoods {
        get {
            return _foods.mapValues { $0.map { AnyFood($0) } }
        } set {
            _foods = newValue.mapValues { $0.map { $0.food } }
        }
    }
    
    private init() {
        if let itemsData = UserDefaults.standard.data(forKey: "items") {
            do {
                savedItems = try JSONDecoder().decode(SavedFoods.self, from: itemsData)
            } catch {
                print(error)
            }
        }
    }
    
    func add(_ food: Food) {
        var foodKey: FoodType?
        if let _ = food as? Salad {
            foodKey = .salad
        }
        
        if let key = foodKey {
            if _foods[key] == nil {
                _foods[key] = [food]
            } else {
                _foods[key]!.append(food)
            }
        }
        
        save()
    }
    
    func remove(_ food: Food, removedSection: ((Bool) -> Void)?) {
        for (key, foods) in _foods {
            for (index, foodInFoods) in foods.enumerated() {
                if food.isEqual(foodInFoods) {
                    _foods[key]!.remove(at: index)
                    if _foods[key]!.isEmpty {
                        _foods.removeValue(forKey: key)
                        removedSection?(true)
                    } else {
                        removedSection?(false)
                    }
                }
            }
        }
        
        save()
    }
    
    func save() {
        do {
            let itemsData = try JSONEncoder().encode(savedItems)
            UserDefaults.standard.set(itemsData, forKey: "items")
        } catch {
            print(error)
        }
    }
    
    func clear() {
        _foods = [:]
        save()
    }
}
