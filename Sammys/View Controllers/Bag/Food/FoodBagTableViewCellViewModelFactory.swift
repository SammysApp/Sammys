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
    private let didEdit: ((FoodBagTableViewCell) -> Void)?
    
    init(food: Food, didEdit: ((FoodBagTableViewCell) -> Void)? = nil) {
        self.food = food
        self.didEdit = didEdit
    }
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodBagTableViewCellConfigurationCommand(food: food, didEdit: didEdit)
        return TableViewCellViewModel(identifier: FoodBagTableViewCellIdentifier.foodCell.rawValue, commands: [.configuration : configurationCommand])
    }
}
