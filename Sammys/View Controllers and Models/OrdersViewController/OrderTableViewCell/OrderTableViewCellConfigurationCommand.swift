//
//  OrderTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderTableViewCellConfigurationCommand: TableViewCellCommand {
	let order: Order
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? OrderTableViewCell else { return }
		cell.numberLabel.text = order.number
	}
}
