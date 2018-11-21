//
//  HomePurchasableTypeCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableTypeCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
	let purchasableType: Purchasable.Type
	let identifier: String
	let width: Double
	let height: Double
    
    func create() -> HomePurchasableTypeCollectionViewCellViewModel {
		let configurationCommand = HomePurchasableTypeCollectionViewCellConfigurationCommand(purchasableType: purchasableType)
		let selectionCommand = HomePurchasableTypeCollectionViewCellSelectionCommand(purchasableType: purchasableType)
        return HomePurchasableTypeCollectionViewCellViewModel(
			purchasableType: purchasableType, identifier: identifier, width: width, height: height, commands: [.configuration: configurationCommand, .selection: selectionCommand]
		)
    }
}
