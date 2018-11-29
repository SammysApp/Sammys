//
//  ActiveOrderOrderTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ActiveOrderOrderTableViewCellConfigurationCommand: TableViewCellCommand {
	let order: Order
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell,
			let activeOrderViewController = parameters.viewController as? ActiveOrderViewController else { return }
		let orderViewController = activeOrderViewController.orderViewController
		orderViewController.viewModelParcel = OrderViewModelParcel(order: order)
		cell.contentView.addSubview(orderViewController.view)
		orderViewController.view.fullViewConstraints(equalTo: cell.contentView).activateAll()
	}
}
