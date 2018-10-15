//
//  FoodHomeCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum FoodHomeCellIdentifier: String {
    case foodCell
}

struct FoodHomeCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
    let size: CGSize
    let titleText: String
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = FoodHomeCollectionViewCellConfigurationCommand(titleText: titleText)
        let commands: [CollectionViewCommandActionKey : CollectionViewCellCommand] = [.configuration: configurationCommand]
        return CollectionViewCellViewModel(identifier: FoodHomeCellIdentifier.foodCell.rawValue, size: size, commands: commands)
    }
}
