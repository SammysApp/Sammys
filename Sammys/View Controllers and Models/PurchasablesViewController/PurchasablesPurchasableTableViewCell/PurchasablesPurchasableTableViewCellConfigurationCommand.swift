//
//  PurchasablesPurchasableTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasablesPurchasableTableViewCellConfigurationCommand: TableViewCellCommand {
	let purchasable: Purchasable
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? PurchasablesPurchasableTableViewCell
			else { return }
		cell.titleLabel.text = purchasable.title
		cell.descriptionLabel.text = purchasable.description
	}
}
