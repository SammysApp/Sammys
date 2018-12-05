//
//  PurchasablesPurchasableTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasablesPurchasableTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let purchasable: Purchasable
	let identifier: String
	let height: Double
	
	func create() -> PurchasablesPurchasableTableViewCellViewModel {
		let configurationCommand = PurchasablesPurchasableTableViewCellConfigurationCommand(purchasable: purchasable)
		return PurchasablesPurchasableTableViewCellViewModel(
			purchasable: purchasable,
			identifier: identifier,
			height: height,
			commands: [.configuration: configurationCommand]
		)
	}
}
