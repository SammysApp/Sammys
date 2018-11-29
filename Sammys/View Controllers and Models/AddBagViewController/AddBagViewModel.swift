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
	var parcel: AddBagViewModelParcel?
	
	private let bagModelController = BagModelController()
	
	var itemedPurchasable: ItemedPurchasable? { return parcel?.itemedPurchasable }
	
	init(_ parcel: AddBagViewModelParcel?) {
		self.parcel = parcel
	}
	
	func add() throws {
		guard let itemedPurchasable = itemedPurchasable else { return }
		try bagModelController.add(itemedPurchasable)
	}
}
