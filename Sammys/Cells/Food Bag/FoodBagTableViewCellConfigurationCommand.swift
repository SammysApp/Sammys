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
    
    init(food: Food) {
        self.food = food
    }
    
    func perform(cell: UITableViewCell?) {
        
    }
}
