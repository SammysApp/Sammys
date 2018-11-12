//
//  BagPurchasableTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct BagPurchasableTableViewCellConfigurationCommand: TableViewCellCommand {
	let purchasableQuantity: PurchasableQuantity
	let delegate: BagPurchasableTableViewCellDelegate?
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? BagPurchasableTableViewCell else { return }
		cell.delegate = delegate
		cell.titleLabel.text = purchasableQuantity.purchasable.title
		cell.descriptionLabel.text = purchasableQuantity.purchasable.description
		cell.priceLabel.text = purchasableQuantity.purchasable.price.priceString
		cell.quantityTextField.placeholder = "\(purchasableQuantity.quantity)"
	}
}
