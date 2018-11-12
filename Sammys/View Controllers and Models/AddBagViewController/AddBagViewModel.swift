//
//  AddBagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct AddBagViewModelParcel {
	let itemedPurchasable: ItemedPurchasable
}

class AddBagViewModel {
	private let parcel: AddBagViewModelParcel
	
	let bagModelController = BagModelController()
	
	var itemedPurchasable: ItemedPurchasable { return parcel.itemedPurchasable }
	
	var foodViewModelParcel: ItemsViewModelParcel {
		return ItemsViewModelParcel(itemedPurchasable: parcel.itemedPurchasable)
	}
	
	init(_ parcel: AddBagViewModelParcel) {
		self.parcel = parcel
	}
	
	func add() throws { try bagModelController.add(itemedPurchasable) }
}
