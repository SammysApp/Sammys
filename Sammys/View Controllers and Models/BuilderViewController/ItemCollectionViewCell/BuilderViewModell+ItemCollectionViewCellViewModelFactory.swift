//
//  BuilderViewModel+ItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension BuilderViewModel {
	struct ItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
		let item: Item
		let identifier: String
		let width: Double
		let height: Double
		
		func create() -> ItemCollectionViewCellViewModel {
			let configurationCommand = ItemCollectionViewCellConfigurationCommand(item: item)
			let selectionCommand = ItemCollectionViewCellSelectionCommand(item: item)
			return ItemCollectionViewCellViewModel(item: item, identifier: identifier, width: width, height: height, commands: [.configuration: configurationCommand, .selection: selectionCommand])
		}
	}
}
