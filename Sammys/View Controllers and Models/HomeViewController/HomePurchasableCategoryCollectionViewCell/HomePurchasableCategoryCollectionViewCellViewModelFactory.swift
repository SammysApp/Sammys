//
//  HomePurchasableCategoryCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableCategoryCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
	let title: String?
	let identifier: String
	let width: Double
	let height: Double
	
    func create() -> HomePurchasableCategoryCollectionViewCellViewModel {
		let configurationCommand = HomePurchasableCategoryCollectionViewCellConfigurationCommand(title: title)
		let selectionCommand = HomePurchasableCategoryCollectionViewCellSelectionCommand()
        return HomePurchasableCategoryCollectionViewCellViewModel(identifier: identifier, width: width, height: height, commands: [.configuration: configurationCommand, .selection: selectionCommand])
    }
}
