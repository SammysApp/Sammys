//
//  AddFoodViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct AddFoodViewModelParcel {
	let food: Food
}

class AddFoodViewModel {
	let parcel: AddFoodViewModelParcel
	
	var foodViewModelParcel: FoodViewModelParcel {
		return FoodViewModelParcel(food: parcel.food)
	}
	
	init(_ parcel: AddFoodViewModelParcel) {
		self.parcel = parcel
	}
}
