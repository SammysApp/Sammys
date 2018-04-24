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
        // Add foods.
        order.foods.forEach {
            $1.forEach {
                models.append(FoodOrderTableViewCellViewModelFactory(food: $0, height: 100).create())
            }
        }
        // Add total information.
        models.append(TotalPriceTableViewCellViewModelFactory(order: order, height: 120).create())
        return models
    }
}
