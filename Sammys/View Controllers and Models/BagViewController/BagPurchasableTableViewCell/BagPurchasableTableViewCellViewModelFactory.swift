//
//  BagPurchasableTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagPurchasableCellIdentifier: String {
    case purchasableCell
}

struct BagPurchasableTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let purchasableQuantity: PurchasableQuantity
	let height: Double
	let delegate: BagPurchasableTableViewCellDelegate?
	
	func create() -> BagPurchasableTableViewCellViewModel {
		return BagPurchasableTableViewCellViewModel(
			purchasableQuantity: purchasableQuantity,
			identifier: BagPurchasableCellIdentifier.purchasableCell.rawValue,
			height: height,
			isEditable: true,
			commands: [.configuration: BagPurchasableTableViewCellConfigurationCommand(purchasableQuantity: purchasableQuantity, delegate: delegate)]
		)
	}
}
