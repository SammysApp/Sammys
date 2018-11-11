//
//  BagPurchaseableTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagPurchaseableCellIdentifier: String {
    case purchaseableCell
}

struct BagPurchaseableTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let purchaseableQuantity: PurchaseableQuantity
	let height: Double
	let delegate: BagPurchaseableTableViewCellDelegate?
	
	func create() -> BagPurchaseableTableViewCellViewModel {
		return BagPurchaseableTableViewCellViewModel(
			purchaseableQuantity: purchaseableQuantity,
			identifier: BagPurchaseableCellIdentifier.purchaseableCell.rawValue,
			height: height,
			isEditable: true,
			commands: [.configuration: BagPurchaseableTableViewCellConfigurationCommand(purchaseableQuantity: purchaseableQuantity, delegate: delegate)]
		)
	}
}
