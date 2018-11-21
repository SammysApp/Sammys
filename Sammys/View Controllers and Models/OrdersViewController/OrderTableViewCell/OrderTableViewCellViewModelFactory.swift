//
//  OrderTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let order: Order
	let identifier: String
	let height: Double
	
	func create() -> OrderTableViewCellViewModel {
		let configurationCommand = OrderTableViewCellConfigurationCommand(order: order)
		return OrderTableViewCellViewModel(order: order, identifier: identifier, height: height, commands: [.configuration: configurationCommand])
	}
}
