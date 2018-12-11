//
//  PurchasableCategoryTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoryTableViewCellConfigurationCommand: TableViewCellCommand {
	let title: String?
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? PurchasableCategoryTableViewCell
			else { return }
		cell.titleLabel.text = title
	}
}
