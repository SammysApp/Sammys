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
	
	private var dateLabelDateFormatter: DateFormatter { return DateFormatter(format: Constants.dateLabelDateFormat) }
	
	private struct Constants {
		static let dateLabelDateFormat = "M/d/yy h:mm a"
	}
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? OrderTableViewCell else { return }
		cell.numberLabel.text = order.number
		cell.descriptionLabel.text = order.description
		cell.dateLabel.text = dateLabelDateFormatter.string(from: order.date)
		cell.priceLabel.text = order.price.total.priceString
	}
}
