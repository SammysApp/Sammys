//
//  BagPurchaseableTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct BagPurchaseableTableViewCellConfigurationCommand: TableViewCellCommand {
	let purchaseable: Purchaseable
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? BagPurchaseableTableViewCell else { return }
		cell.titleLabel.text = purchaseable.title
		cell.descriptionLabel.text = purchaseable.description
		cell.priceLabel.text = purchaseable.price.priceString
	}
}
