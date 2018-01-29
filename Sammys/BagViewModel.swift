//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class BagViewModel {
    var user: User? {
        return UserDataStore.shared.user
    }
    var items: [FoodType : [BagItem]] {
        var items = [FoodType : [BagItem]]()
        for key in sortedItemsKeys {
            if let keyFoods = foods[key] {
                for food in keyFoods {
                    if items[key] == nil {
                        items[key] = []
                    }
                    let foodItem = FoodBagItem(food: food)
                    items[key]!.append(foodItem)
                    let quantityItem = QuantityBagItem(food: food)
                    items[key]!.append(quantityItem)
                }
            }
        }
        return items
    }
    
    private let data = BagDataStore.shared
    private var foods: BagDataStore.Foods {
        return data.foods
    }
    private var sortedItemsKeys: [FoodType] {
        return Array(foods.keys).sorted { $0.rawValue < $1.rawValue }
    }
    
    var subtotalPrice: Double {
        var totalPrice = 0.0
        foods.forEach { $1.forEach { totalPrice += $0.price } }
        return totalPrice.rounded(toPlaces: 2)
    }
    var taxPrice: Double {
        return (subtotalPrice * (6.88/100)).rounded(toPlaces: 2)
    }
    var finalPrice: Double {
        return (subtotalPrice + taxPrice).rounded(toPlaces: 2)
    }
    
    var numberOfSections: Int {
        return items.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        let key = sortedItemsKeys[section]
        return items[key]?.count ?? 0
    }
    
    func item(for indexPath: IndexPath) -> BagItem? {
        let key = sortedItemsKeys[indexPath.section]
        if let items = items[key] {
            return items[indexPath.row]
        }
        return nil
    }
    
    func indexPath(for food: Food) -> IndexPath? {
        for (section, key) in sortedItemsKeys.enumerated() {
            if let items = items[key] {
                for (row, item) in items.enumerated() {
                    if let foodItem = item as? FoodBagItem {
                        if foodItem.food.isEqual(food) {
                            return IndexPath(row: row, section: section)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func remove(_ food: Food, removedSection: ((Bool) -> Void)?) {
        data.remove(food, removedSection: removedSection)
    }
    
    func finishEditing() {
        data.save()
    }
    
    func clearBag() {
        data.clear()
    }
}

enum BagItemKey {
    case food
    case quantity
}

protocol BagItem {
    var key: BagItemKey { get }
}

class FoodBagItem: BagItem {
    let key: BagItemKey = .food
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}

class QuantityBagItem: BagItem {
    let key: BagItemKey = .quantity
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}
