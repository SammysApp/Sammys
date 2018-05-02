//
//  FoodBagTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodBagTableViewCellViewModel: TableViewCellViewModel {
    let food: Food
    let identifier: String
    let height: CGFloat
    let commands: [TableViewCommandActionKey : TableViewCellCommand]
}

enum FoodBagTableViewCellIdentifier: String {
    case foodCell
}

struct FoodBagTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let food: Food
    let height: CGFloat
    let didSelect: ((Food) -> Void)?
    let didEdit: ((FoodBagTableViewCell) -> Void)?
    let didSelectQuantity: ((Food, Quantity) -> Void)
    
    init(food: Food, height: CGFloat, didSelect: ((Food) -> Void)? = nil, didEdit: ((FoodBagTableViewCell) -> Void)? = nil, didSelectQuantity: @escaping ((Food, Quantity) -> Void)) {
        self.food = food
        self.height = height
        self.didSelect = didSelect
        self.didEdit = didEdit
        self.didSelectQuantity = didSelectQuantity
    }
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodBagTableViewCellConfigurationCommand(food: food, didEdit: didEdit, didSelectQuantity: didSelectQuantity)
        let selectionCommand = FoodBagTableViewCellSelectionCommand(food: food, didSelect: didSelect)
        return FoodBagTableViewCellViewModel(food: food, identifier: FoodBagTableViewCellIdentifier.foodCell.rawValue, height: height, commands: [.configuration : configurationCommand, .selection: selectionCommand])
    }
}
