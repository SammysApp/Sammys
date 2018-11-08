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
	let purchaseable: Purchaseable
	let height: Double
	
	func create() -> BagPurchaseableTableViewCellViewModel {
		return BagPurchaseableTableViewCellViewModel(purchaseable: purchaseable, identifier: BagPurchaseableCellIdentifier.purchaseableCell.rawValue, height: height, isEditable: true, commands: [.configuration: BagPurchaseableTableViewCellConfigurationCommand(purchaseable: purchaseable)])
	}
}
