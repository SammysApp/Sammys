//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum ItemCellIdentifier: String {
    case itemCell
}

struct ItemCollectionViewCellViewModelFactory/*: CollectionViewCellViewModelFactory*/ {
//    private let item: Item
//    private let size: CGSize
//    private let shouldHideItemLabel: Bool
//    private let shouldShowSelected: Bool
//    
//    init(item: Item, size: CGSize, shouldHideItemLabel: Bool = false, shouldShowSelected: Bool = false) {
//        self.item = item
//        self.size = size
//        self.shouldHideItemLabel = shouldHideItemLabel
//        self.shouldShowSelected = shouldShowSelected
//    }
//    
//    func create() -> CollectionViewCellViewModel {
//        let configurationCommand = ItemCollectionViewCellConfigurationCommand(item: item, shouldHideItemLabel: shouldHideItemLabel, shouldShowSelected: shouldShowSelected)
//        let selectionCommand = ItemCollectionViewCellSelectionCommand(item: item)
//        return CollectionViewCellViewModel(identifier: ItemCellIdentifier.itemCell.rawValue, size: size, commands: [.configuration : configurationCommand, .selection: selectionCommand])
//    }
}
