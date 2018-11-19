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
			do { try ordersViewController.viewModelParcel = userViewController.viewModel.ordersViewModelParcel() }
			catch { print(error); return }
			if userViewController.isViewLoaded { userViewController.navigationController?.pushViewController(ordersViewController, animated: true) }
		}
	}
}
