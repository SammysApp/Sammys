//
//  ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension ItemsViewModel {
	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let item: Item
		let identifier: String
		let width: Double
		let height: Double
		
		func create() -> DefaultCollectionViewCellViewModel {
			let configurationCommand = ItemCollectionViewCellConfigurationCommand(item: item)
			return DefaultCollectionViewCellViewModel(identifier: identifier, width: width, height: height, commands: [.configuration: configurationCommand])
		}
	}
}
