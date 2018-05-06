//
//  FoodHomeCollectionViewCellCofigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodHomeCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    let titleText: String
    
    private struct Constants {
        static let cornerRadius: CGFloat = 20
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? FoodHomeCollectionViewCell else { return }
        cell.itemsLabel.text = titleText
        cell.layer.cornerRadius = Constants.cornerRadius
    }
}
