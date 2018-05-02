//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

private enum ItemCellIdentifier: String {
    case itemCell
}

struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
    private let item: Item
    private let size: CGSize
    
    init(item: Item, size: CGSize) {
        self.item = item
        self.size = size
    }
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = ItemCollectionViewCellConfigurationCommand(item: item)
        let selectionCommand = ItemCollectionViewCellSelectionCommand(item: item)
        return CollectionViewCellViewModel(identifier: ItemCellIdentifier.itemCell.rawValue, size: size, commands: [.configuration : configurationCommand, .selection: selectionCommand])
    }
}