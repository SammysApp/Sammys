//
//  FoodOrderTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum FoodOrderCellIdentifier: String {
    case foodCell
}

struct FoodOrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let food: Food
    
    func create() -> TableViewCellViewModel {
        return TableViewCellViewModel(identifier: FoodOrderCellIdentifier.foodCell.rawValue, commands: [.configuration: FoodOrderTableViewCellConfigurationCommand(food: food)])
    }
}
