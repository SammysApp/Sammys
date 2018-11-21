//
//  OrderPurchasableTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrderPurchasableTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let purchasableQuantity: PurchasableQuantity
	let identifier: String
	let height: Double
	
	func create() -> OrderPurchasableTableViewCellViewModel {
		let configurationCommand = OrderPurchasableTableViewCellConfigurationCommand(purchasableQuantity: purchasableQuantity)
		return OrderPurchasableTableViewCellViewModel(
			purchaseableQuantity: purchasableQuantity,
			identifier: identifier,
			height: height,
			commands: [.configuration : configurationCommand]
		)
	}
}
