//
//  OrderTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let identifier: String
	let height: Double
	let order: Order
	
	func create() -> DefaultTableViewCellViewModel {
		let configurationCommand = OrderTableViewCellConfigurationCommand(order: order)
		return DefaultTableViewCellViewModel(identifier: identifier, height: height, commands: [.configuration: configurationCommand])
	}
}
