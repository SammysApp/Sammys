//
//  FoodBagTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodBagTableViewCellConfigurationCommand: TableViewCellCommand {
    private let food: Food
    private let didEdit: ((FoodBagTableViewCell) -> Void)?
    
    init(food: Food, didEdit: ((FoodBagTableViewCell) -> Void)? = nil) {
        self.food = food
        self.didEdit = didEdit
    }
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? FoodBagTableViewCell else { return }
        switch food {
        case let salad as Salad:
            cell.titleLabel.text = "\(salad.size!.name) Salad"
        default: break
        }
        
        cell.descriptionLabel.text = food.itemDescription
        cell.priceLabel.text = food.price.priceString
        cell.didEdit = didEdit
    }
}
