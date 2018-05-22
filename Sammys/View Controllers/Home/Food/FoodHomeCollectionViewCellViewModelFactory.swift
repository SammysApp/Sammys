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
    let selectionCommand: CollectionViewCellCommand?
    
    init(size: CGSize, titleText: String, selectionCommand: CollectionViewCellCommand? = nil) {
        self.size = size
        self.titleText = titleText
        self.selectionCommand = selectionCommand
    }
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = FoodHomeCollectionViewCellConfigurationCommand(titleText: titleText)
        var commands: [CollectionViewCommandActionKey : CollectionViewCellCommand] = [.configuration: configurationCommand]
        if let selectionCommand = selectionCommand {
            commands[.selection] = selectionCommand
        }
        return CollectionViewCellViewModel(identifier: FoodHomeCellIdentifier.foodCell.rawValue, size: size, commands: commands)
    }
}
