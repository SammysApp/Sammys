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
        
        cell.quantityCollectionView.viewModel = QuantityCollectionViewModel(textColor: #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1), backgroundColor: #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1), deleteBackgroundColor: #colorLiteral(red: 0.9490196078, green: 0.2705882353, blue: 0.3215686275, alpha: 1)) { quantity in
            self.didSelectQuantity(self.food, quantity)
        }
        
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.width / 2
    }
}
