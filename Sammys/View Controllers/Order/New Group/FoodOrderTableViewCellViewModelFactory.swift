//
//  FoodOrderTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum FoodOrderCellIdentifier: String {
    case foodCell
}

struct FoodOrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let food: Food
    let height: CGFloat
    
    func create() -> TableViewCellViewModel {
        return TableViewCellViewModel(identifier: FoodOrderCellIdentifier.foodCell.rawValue, height: height, commands: [.configuration: FoodOrderTableViewCellConfigurationCommand(food: food)])
    }
}
