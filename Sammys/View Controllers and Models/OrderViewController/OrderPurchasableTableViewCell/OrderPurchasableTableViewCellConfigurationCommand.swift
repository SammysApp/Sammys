//
//  OrderPurchasableTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderPurchasableTableViewCellConfigurationCommand: TableViewCellCommand {
	let purchasableQuantity: PurchasableQuantity
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? OrderPurchasableTableViewCell else { return }
		cell.quantityLabel.text = "\(purchasableQuantity.quantity)"
		cell.titleLabel.text = purchasableQuantity.purchasable.title
		cell.descriptionLabel.text = purchasableQuantity.purchasable.description
		cell.priceLabel.text = purchasableQuantity.quantitativePrice.priceString
	}
}
