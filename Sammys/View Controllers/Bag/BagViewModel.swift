//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagItemKey {
    case food, quantity
}

protocol BagItem {
    var key: BagItemKey { get }
    var cellIdenitifier: BagCellIdentifier { get }
}

enum BagCellIdentifier: String {
    case foodCell, quantityCell
}

struct BagItemGroup {
    let items: [BagItem]
}

struct BagSection {
    let title: String?
    let itemGroups: [BagItemGroup]
    
    var allItems: [BagItem] {
        return itemGroups.flatMap { $0.items }
    }
    
    init(title: String? = nil, itemGroups: [BagItemGroup]) {
        self.title = title
        self.itemGroups = itemGroups
    }
}

class BagViewModel {
    var user: User? {
        return UserDataStore.shared.user
    }
    
    private let data = BagDataStore.shared
    
    private var foods: BagDataStore.Foods {
        return data.foods
    }
    
    private var sortedFoodTypes: [FoodType] {
        return Array(foods.keys).sorted { $0.rawValue < $1.rawValue }
    }
    
    private var sections: [BagSection] {
        var sections = [BagSection]()
        for foodType in sortedFoodTypes {
            if let foods = foods[foodType] {
                var itemGroups = [BagItemGroup]()
                for food in foods {
                    var items = [BagItem]()
                    items.append(FoodBagItem(food: food))
                    if let quantityItem = quantityItem(for: food) {
                        items.append(quantityItem)
                    }
                    itemGroups.append(BagItemGroup(items: items))
                }
                sections.append(BagSection(itemGroups: itemGroups))
            }
        }
        return sections
    }
    
    private var quantityItems = [QuantityBagItem]()
    
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
        return sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].allItems.count
    }
    
    func item(for indexPath: IndexPath) -> BagItem? {
        return sections[indexPath.section].allItems[indexPath.row]
    }
    
    func remove(at indexPath: IndexPath, didRemoveSection: ((Bool) -> Void)?) {
        guard let food = (item(for: indexPath) as? FoodBagItem)?.food else { return }
        data.remove(food, didRemoveSection: didRemoveSection)
    }
    
    func quantityItem(for food: Food) -> QuantityBagItem? {
        return quantityItems.first { $0.food.isEqual(food) }
    }
    
    func showQuantity(for food: Food) {
        quantityItems.append(QuantityBagItem(food: food))
    }
    
    func hideQuantity(for food: Food) {
        quantityItems = quantityItems.filter { !$0.food.isEqual(food) }
    }
    
    func finishEditing() {
        data.save()
    }
    
    func clearBag() {
        data.clear()
    }
}

class FoodBagItem: BagItem {
    let key: BagItemKey = .food
    let cellIdenitifier: BagCellIdentifier = .foodCell
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}

class QuantityBagItem: BagItem {
    let key: BagItemKey = .quantity
    let cellIdenitifier: BagCellIdentifier = .quantityCell
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}
