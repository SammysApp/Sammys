//
//  FoodTableViewCellConfigurationCommand.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodTableViewCellConfigurationCommand: TableViewCellCommand {
    let food: Food
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? FoodTableViewCell else { return }
        cell.titleLabel.text = food.title
        cell.descriptionLabel.text = food.itemDescription
    }
}
