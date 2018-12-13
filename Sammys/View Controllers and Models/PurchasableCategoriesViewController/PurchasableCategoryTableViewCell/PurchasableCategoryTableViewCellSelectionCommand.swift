//
//  PurchasableCategoryTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoryTableViewCellSelectionCommand: TableViewCellCommand {
	let category: PurchasableCategoryNode
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let purchasableCategoriesiewController = parameters.viewController as? PurchasableCategoriesViewController else { return }
		if let next = category.next {
			switch next {
			case .itemedPurchasable(let data):
				let builderViewController = purchasableCategoriesiewController.builderViewController
				builderViewController.viewModelParcel = BuilderViewModelParcel.init(categories: data.categories, itemsPromises: data.promises, builder: data.builder, userState: purchasableCategoriesiewController.viewModel.userState)
				purchasableCategoriesiewController.navigationController?.pushViewController(builderViewController, animated: true)
			default: break
			}
		}
	}
}
