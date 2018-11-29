//
//  ActiveOrderMapTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ActiveOrderMapTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let identifier: String
    let height: Double
	
	func create() -> DefaultTableViewCellViewModel {
		let configurationCommand = ActiveOrderMapTableViewCellConfigurationCommand()
		let selectionCommand = ActiveOrderMapTableViewCellSelectionCommand()
		return DefaultTableViewCellViewModel(identifier: identifier, height: height, commands: [.configuration: configurationCommand, .selection: selectionCommand])
	}
}
