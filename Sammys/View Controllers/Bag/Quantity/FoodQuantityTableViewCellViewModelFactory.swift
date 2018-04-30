//
//  FoodQuantityTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum FoodQuantityCellIdentifier: String {
    case quantityCell
}

struct FoodQuantityTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let food: Food
    let height: CGFloat
    let didSelectQuantity: ((Food, Quantity) -> Void)
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodQuantityTableViewCellConfigurationCommand(food: food, didSelectQuantity: didSelectQuantity)
        return TableViewCellViewModel(identifier: FoodQuantityCellIdentifier.quantityCell.rawValue, height: height, commands: [.configuration: configurationCommand])
    }
}
