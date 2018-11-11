//
//  AddFoodViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct AddFoodViewModelParcel {
	let itemedPurchaseable: ItemedPurchaseable
}

class AddFoodViewModel {
	private let parcel: AddFoodViewModelParcel
	
	let bagModelController = BagModelController()
	
	var itemedPurchaseable: ItemedPurchaseable { return parcel.itemedPurchaseable }
	
	var foodViewModelParcel: FoodViewModelParcel {
		return FoodViewModelParcel(itemedPurchaseable: parcel.itemedPurchaseable)
	}
	
	init(_ parcel: AddFoodViewModelParcel) {
		self.parcel = parcel
	}
	
	func add() throws { try bagModelController.add(itemedPurchaseable) }
}
