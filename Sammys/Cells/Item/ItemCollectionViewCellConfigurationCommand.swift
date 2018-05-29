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
    private let shouldShowSelected: Bool
    
    private struct Constants {
        static let cornerRadius: CGFloat = 20
    }
    
    init(item: Item, shouldHideItemLabel: Bool, shouldShowSelected: Bool) {
        self.item = item
        self.shouldHideItemLabel = shouldHideItemLabel
        self.shouldShowSelected = shouldShowSelected
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? ItemCollectionViewCell else {
            return
        }
        
        cell.layer.cornerRadius = Constants.cornerRadius
        cell.backgroundColor = shouldShowSelected ? .white : item.color
        cell.titleLabel.text = item.name
        cell.titleLabel.isHidden = shouldHideItemLabel
        
        if let price = item.price, !shouldHideItemLabel {
            cell.priceLabel.isHidden = false
            cell.priceLabel.text = price.priceString
        } else {
            cell.priceLabel.isHidden = true
        }
    }
}
