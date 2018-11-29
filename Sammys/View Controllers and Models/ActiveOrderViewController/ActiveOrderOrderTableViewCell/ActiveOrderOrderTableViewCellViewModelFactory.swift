//
//  ActiveOrderOrderTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ActiveOrderOrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let order: Order
	let identifier: String
	let height: Double
	
	func create() -> DefaultTableViewCellViewModel {
		let configurationCommand = ActiveOrderOrderTableViewCellConfigurationCommand(order: order)
		return DefaultTableViewCellViewModel(identifier: identifier, height: height, commands: [.configuration: configurationCommand])
	}
}
