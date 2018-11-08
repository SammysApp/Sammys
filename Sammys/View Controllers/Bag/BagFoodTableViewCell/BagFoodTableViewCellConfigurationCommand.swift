//
//  BagFoodTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct BagFoodTableViewCellConfigurationCommand: TableViewCellCommand {
	let food: Food
	
	func perform(parameters: TableViewCellCommandParameters) {
		guard let cell = parameters.cell as? BagFoodTableViewCell else { return }
		cell.priceLabel.text = food.price.priceString
	}
}
