//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension ItemsViewModel {
	enum ItemCellIdentifier: String {
		case itemCell
	}

	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let foodItem: FoodItem
		let width: Double
		let height: Double
		
		func create() -> ItemCollectionViewCellViewModel {
			return ItemCollectionViewCellViewModel(foodItem: foodItem, identifier: ItemCellIdentifier.itemCell.rawValue, width: width, height: height, commands: [.configuration: ItemCollectionViewCellConfigurationCommand(foodItem: foodItem)])
		}
	}
}
