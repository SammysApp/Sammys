//
//  ItemCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ItemCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    private let item: Item
    private let shouldHideItemLabel: Bool
    
    private struct Constants {
        static let cornerRadius: CGFloat = 20
    }
    
    init(item: Item, shouldHideItemLabel: Bool) {
        self.item = item
        self.shouldHideItemLabel = shouldHideItemLabel
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? ItemCollectionViewCell else {
            return
        }
        
        cell.layer.cornerRadius = Constants.cornerRadius
        cell.backgroundColor = item.color
        cell.titleLabel.text = item.name
        cell.titleLabel.isHidden = shouldHideItemLabel
    }
}
