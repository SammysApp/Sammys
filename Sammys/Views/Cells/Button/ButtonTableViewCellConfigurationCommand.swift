//
//  ButtonTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ButtonTableViewCellConfigurationCommand: TableViewCellCommand {
	let buttonText: String
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell else { return }
		cell.textLabel?.text = buttonText
	}
}
