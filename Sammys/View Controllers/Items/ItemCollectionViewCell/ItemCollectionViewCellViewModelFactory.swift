//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension ItemsViewModel {
	enum ItemCellIdentifier: String {
		case itemCell
	}

	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let foodItem: FoodItem
		let size: CGSize
		
		func create() -> ItemCollectionViewCellViewModel {
			let configurationCommand = ItemCollectionViewCellConfigurationCommand(foodItem: foodItem)
			return ItemCollectionViewCellViewModel(foodItem: foodItem, identifier: ItemCellIdentifier.itemCell.rawValue, size: size, commands: [.configuration: configurationCommand])
		}
	}
}
