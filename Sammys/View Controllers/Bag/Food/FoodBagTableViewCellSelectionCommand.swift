//
//  FoodBagTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodBagTableViewCellSelectionCommand: TableViewCellCommand {
    let food: Food
    let didSelect: ((Food) -> Void)?
    
    func perform(cell: UITableViewCell?) {
        //guard let cell = cell as? FoodBagTableViewCell else { return }
        didSelect?(food)
    }
}
