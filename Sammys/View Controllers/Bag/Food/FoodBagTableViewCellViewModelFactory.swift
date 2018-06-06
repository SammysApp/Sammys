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

enum FoodBagCellIdentifier: String {
    case foodCell
}

struct FoodBagTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let user: User?
    let food: Food
    let height: CGFloat
    let didSelect: ((Food) -> Void)?
    let didEdit: ((FoodBagTableViewCell) -> Void)?
    let didFave: ((FoodBagTableViewCell) -> Void)?
    let selectedQuantity: () -> Int
    let didSelectQuantity: ((Food, Quantity) -> Void)
    
    init(user: User? = nil, food: Food, height: CGFloat, selectedQuantity: @escaping () -> Int, didSelect: ((Food) -> Void)? = nil, didEdit: ((FoodBagTableViewCell) -> Void)? = nil, didFave: ((FoodBagTableViewCell) -> Void)? = nil, didSelectQuantity: @escaping ((Food, Quantity) -> Void)) {
        self.user = user
        self.food = food
        self.height = height
        self.selectedQuantity = selectedQuantity
        self.didSelect = didSelect
        self.didEdit = didEdit
        self.didFave = didFave
        self.didSelectQuantity = didSelectQuantity
    }
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = FoodBagTableViewCellConfigurationCommand(user: user, food: food, selectedQuantity: selectedQuantity, didEdit: didEdit, didFave: didFave, didSelectQuantity: didSelectQuantity)
        let selectionCommand = FoodBagTableViewCellSelectionCommand(food: food, didSelect: didSelect)
        return FoodBagTableViewCellViewModel(food: food, identifier: FoodBagCellIdentifier.foodCell.rawValue, height: height, commands: [.configuration : configurationCommand, .selection: selectionCommand])
    }
}
