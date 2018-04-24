//
//  OrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class OrderViewModel {
    let order: Order
    
    init(order: Order) {
        self.order = order
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return cellViewModels.count
    }
    
    var cellViewModels: [TableViewCellViewModel] {
        var models = [TableViewCellViewModel]()
        order.foods.forEach { pair in
            pair.value.forEach { models.append(FoodOrderTableViewCellViewModelFactory(food: $0).create()) }
        }
        return models
    }
}
