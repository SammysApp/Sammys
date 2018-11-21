//
//  UserViewModel+OrdersButtonTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension UserViewModel {
	struct OrdersButtonTableViewCellSelectionCommand: TableViewCellCommand {
		func perform(parameters: TableViewCellCommandParameters) {
			guard let userViewController = parameters.viewController as? UserViewController else { return }
			let ordersViewController = userViewController.ordersViewController
			if let user = userViewController.viewModel.user {
				ordersViewController.viewModelParcel = OrdersViewModelParcel.init(user: user)
			}
			if userViewController.isVisible { userViewController.navigationController?.pushViewController(ordersViewController, animated: true) }
		}
	}
}
