//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension FoodViewModel {
	enum ItemCellIdentifier: String {
		case itemCell
	}

	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let foodItem: Item
		let width: Double
		let height: Double
		
		func create() -> DefaultCollectionViewCellViewModel {
			return DefaultCollectionViewCellViewModel(identifier: ItemCellIdentifier.itemCell.rawValue, width: width, height: height, commands: [.configuration: ItemCollectionViewCellConfigurationCommand(foodItem: foodItem)])
		}
	}
}
