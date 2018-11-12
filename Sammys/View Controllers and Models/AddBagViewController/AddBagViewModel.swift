//
//  AddBagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct AddBagViewModelParcel {
	let itemedPurchaseable: ItemedPurchaseable
}

class AddBagViewModel {
	private let parcel: AddBagViewModelParcel
	
	let bagModelController = BagModelController()
	
	var itemedPurchaseable: ItemedPurchaseable { return parcel.itemedPurchaseable }
	
	var foodViewModelParcel: ItemsViewModelParcel {
		return ItemsViewModelParcel(itemedPurchaseable: parcel.itemedPurchaseable)
	}
	
	init(_ parcel: AddBagViewModelParcel) {
		self.parcel = parcel
	}
	
	func add() throws { try bagModelController.add(itemedPurchaseable) }
}
