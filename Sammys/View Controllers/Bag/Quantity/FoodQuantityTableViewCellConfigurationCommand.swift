//
//  FoodQuantityTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodQuantityTableViewCellConfigurationCommand: TableViewCellCommand {
    let food: Food
    let didSelectQuantity: ((Food, Quantity) -> Void)
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? FoodQuantityTableViewCell else { return }
        cell.quantityCollectionView.didSelectQuantity = { quantity in
            self.didSelectQuantity(self.food, quantity)
        }
    }
}
