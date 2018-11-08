//
//  BagFoodTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagFoodCellIdentifier: String {
    case foodCell
}

struct BagFoodTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let food: Food
	let height: Double
	
	func create() -> BagFoodTableViewCellViewModel {
		return BagFoodTableViewCellViewModel(food: food, identifier: BagFoodCellIdentifier.foodCell.rawValue, height: height, commands: [.configuration: BagFoodTableViewCellConfigurationCommand(food: food)])
	}
}
