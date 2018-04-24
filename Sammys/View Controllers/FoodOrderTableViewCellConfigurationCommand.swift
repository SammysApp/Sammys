//
//  FoodOrderTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodOrderTableViewCellConfigurationCommand: TableViewCellCommand {
    let food: Food
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? FoodOrderTableViewCell else { return }
        cell.quantityLabel.text = "\(food.quantity)"
        cell.nameLabel.text = food.title
        cell.priceLabel.text = food.price.priceString
    }
}
