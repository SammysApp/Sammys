//
//  BagPurchaseableTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct BagPurchaseableTableViewCellConfigurationCommand: TableViewCellCommand {
	let purchaseableQuantity: PurchaseableQuantity
	let delegate: BagPurchaseableTableViewCellDelegate?
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? BagPurchaseableTableViewCell else { return }
		cell.delegate = delegate
		cell.titleLabel.text = purchaseableQuantity.purchaseable.title
		cell.descriptionLabel.text = purchaseableQuantity.purchaseable.description
		cell.priceLabel.text = purchaseableQuantity.purchaseable.price.priceString
		cell.quantityTextField.placeholder = "\(purchaseableQuantity.quantity)"
	}
}
