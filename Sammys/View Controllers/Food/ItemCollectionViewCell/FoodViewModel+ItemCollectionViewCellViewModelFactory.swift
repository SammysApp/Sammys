//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension FoodViewModel {
	enum ItemCellIdentifier: String {
		case itemCell
	}

	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let foodItem: FoodItem
		let width: Double
		let height: Double
		
		func create() -> DefaultCollectionViewCellViewModel {
			let configurationCommand = ItemCollectionViewCellConfigurationCommand(foodItem: foodItem)
			return DefaultCollectionViewCellViewModel(identifier: ItemCellIdentifier.itemCell.rawValue, size: CGSize(width: width, height: height), commands: [.configuration: configurationCommand])
		}
	}
}
