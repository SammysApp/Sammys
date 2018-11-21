//
//  HomePurchasableTypeCollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableTypeCollectionViewCellViewModel: CollectionViewCellViewModel {
	let purchasableType: Purchasable.Type
	let identifier: String
	let width: Double
	let height: Double
	let commands: [CollectionViewCommandActionKey : CollectionViewCellCommand]
}