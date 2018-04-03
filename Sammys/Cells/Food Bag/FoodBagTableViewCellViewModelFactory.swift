//
//  FoodBagTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum FoodBagTableViewCellIdentifier: String {
    case foodCell
}

struct FoodBagTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    private let food: Food
    
    init(food: Food) {
        self.food = food
    }
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodBagTableViewCellConfigurationCommand(food: food)
        return TableViewCellViewModel(identifier: FoodBagTableViewCellIdentifier.foodCell.rawValue, commands: [.configuration : configurationCommand])
    }
}
