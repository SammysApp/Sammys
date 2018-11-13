//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension BuilderViewModel {
	enum ItemCellIdentifier: String {
		case itemCell
	}

	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let item: Item
		let width: Double
		let height: Double
		
		func create() -> ItemCollectionViewCellViewModel {
			return ItemCollectionViewCellViewModel(item: item, identifier: ItemCellIdentifier.itemCell.rawValue, width: width, height: height, commands: [.configuration: ItemCollectionViewCellConfigurationCommand(item: item)])
		}
	}
}
