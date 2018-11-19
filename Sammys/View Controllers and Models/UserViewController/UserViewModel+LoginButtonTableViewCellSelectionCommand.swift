//
//  UserViewModel+LoginButtonTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension UserViewModel {
	struct LoginButtonTableViewCellSelectionCommand: TableViewCellCommand {
		func perform(parameters: TableViewCellCommandParameters) {
			guard let userViewController = parameters.viewController as? UserViewController else { return }
			userViewController.logOut()
		}
	}
}
