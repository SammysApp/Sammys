//
//  PurchasableCategoryTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoryTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let category: PurchasableCategoryNode
	let identifier: String
	let height: Double
	
	func create() -> PurchasableCategoryTableViewCellViewModel {
		let configurationCommand = PurchasableCategoryTableViewCellConfigurationCommand(title: category.title)
		return PurchasableCategoryTableViewCellViewModel(
			category: category,
			identifier: identifier,
			height: height,
			commands: [.configuration: configurationCommand]
		)
	}
}
