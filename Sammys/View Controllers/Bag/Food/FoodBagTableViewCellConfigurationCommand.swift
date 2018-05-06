//
//  FoodBagTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodBagTableViewCellConfigurationCommand: TableViewCellCommand {
    let food: Food
    let didEdit: ((FoodBagTableViewCell) -> Void)?
    let didSelectQuantity: ((Food, Quantity) -> Void)
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? FoodBagTableViewCell else { return }
        let foodType = type(of: food).type
        
        switch foodType {
        case .salad:
            let salad = food as! Salad
            cell.titleLabel.text = "\(salad.size!.name) Salad"
        }
        
        cell.descriptionLabel.text = food.itemDescription
        cell.priceLabel.text = food.price.priceString
        cell.didEdit = didEdit
        cell.quantityCollectionView.didSelectQuantity = { quantity in
            self.didSelectQuantity(self.food, quantity)
        }
    }
}
