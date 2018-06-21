//
//  FoodTableViewCellViewModelFactory.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum FoodCellIdentifier: String {
    case foodCell
}

struct FoodTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let food: Food
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodTableViewCellConfigurationCommand(food: food)
        return DefaultTableViewCellViewModel(identifier: FoodCellIdentifier.foodCell.rawValue, height: 80, commands: [.configuration: configurationCommand])
    }
}
