//
//  TableViewCellCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct TableViewCellCommandParameters {
	let cell: UITableViewCell?
	let viewController: UIViewController?
	
	init(cell: UITableViewCell? = nil, viewController: UIViewController? = nil) {
		self.cell = cell
		self.viewController = viewController
	}
}

protocol TableViewCellCommand {
	func perform(parameters: TableViewCellCommandParameters)
}

enum TableViewCommandActionKey {
    case configuration
    case selection
}
