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
    typealias SavedItems = [FoodKey : [AnyFood]]
    
    static let shared = BagDataStore()
    private var _items: Items = [:]
    var items: Items {
        return _items
    }
    private var savedItems: SavedItems {
        get {
            return _items.mapValues { $0.map { AnyFood($0) } }
        } set {
            _items = newValue.mapValues { $0.map { $0.food } }
        }
    }
    
    private init() {
        if let itemsData = UserDefaults.standard.data(forKey: "items") {
            do {
                savedItems = try JSONDecoder().decode(SavedItems.self, from: itemsData)
            } catch {
                print(error)
            }
        }
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
        _items = [:]
    }
}
