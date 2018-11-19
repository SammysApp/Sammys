//
//  ButtonTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ButtonTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let identifier: String
    let height: Double
    let buttonText: String
	let selectionCommand: TableViewCellCommand
	
	func create() -> DefaultTableViewCellViewModel {
		let configurationCommand = ButtonTableViewCellConfigurationCommand(buttonText: buttonText)
		return DefaultTableViewCellViewModel(identifier: identifier, height: height, commands: [.configuration: configurationCommand, .selection: selectionCommand])
	}
}
