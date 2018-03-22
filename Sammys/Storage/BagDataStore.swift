//
//  BagDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A singleton type that stores 📦 bag 🎒 data.
class BagDataStore {
    /// Represents a data structure of foods in bag.
    typealias Foods = [FoodType: [Food]]
    
    /// Represents a data structure to save `Foods` to disk.
    private typealias SavedFoods = [FoodType : [AnyFood]]
    
    /// The shared single instance.
    static let shared = BagDataStore()
    
    /// The private mutable foods in the bag.
    private var _foods: Foods = [:]
    
    /// The foods in the bag.
    var foods: Foods {
        return _foods
    }
    
    /// The foods mapped to `AnyFood` and able to save to disk.
    private var savedFoods: SavedFoods {
        get {
            return _foods.mapValues { $0.map { AnyFood($0) } }
        } set {
            _foods = newValue.mapValues { $0.map { $0.food } }
        }
    }
    
    private init() {
        // Attempt to decode food data from disk.
        if let foodData = UserDefaults.standard.data(forKey: "foods") {
            do {
                savedFoods = try JSONDecoder().decode(SavedFoods.self, from: foodData)
            } catch {
                print(error)
            }
        }
    }
    
    /**
     Adds food to stored foods or increments quantity if equals existing one.
     - Parameter food: The food to add.
    */
    func add(_ food: Food) {
        let key = type(of: food).type
        if var foodsForKey = _foods[key] {
            var added = false
            for var foodInFoods in foodsForKey {
                if foodInFoods.isEqual(food) {
                    foodInFoods.quantity += 1
                    added = true
                    break
                }
            }
            if !added {
                foodsForKey.append(food)
            }
        } else {
            _foods[key] = [food]
        }
        
        save()
    }
    
    /**
     Remove given food in stored foods.
     - Parameter food: The food to remove.
     - Parameter removedSection: A closure that gets sent `true` if removed the section containing the food removed.
     */
    func remove(_ food: Food, removedSection: ((Bool) -> Void)? = nil) {
        for (key, foods) in _foods {
            for (index, foodInFoods) in foods.enumerated() {
                if food.isEqual(foodInFoods) {
                    if var foodsForKey = _foods[key] {
                        foodsForKey.remove(at: index)
                        if foodsForKey.isEmpty {
                            _foods.removeValue(forKey: key)
                            removedSection?(true)
                        } else {
                            removedSection?(false)
                        }
                    }
                }
            }
        }
        
        save()
    }
    
    /// Saves the foods to disk.
    func save() {
        do {
            let foodData = try JSONEncoder().encode(savedFoods)
            UserDefaults.standard.set(foodData, forKey: "foods")
        } catch {
            print(error)
        }
    }
    
    /// Clears the stored foods.
    func clear() {
        _foods = [:]
        save()
    }
}
