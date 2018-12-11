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
	let userState: UserState
}

class AddBagViewModel {
	var parcel: AddBagViewModelParcel?
	
	private let bagModelController = BagModelController()
	private let userAPIManager = UserAPIManager()
	
	var itemedPurchasable: ItemedPurchasable? { return parcel?.itemedPurchasable }
	lazy var userState = { parcel?.userState ?? .noUser }()
	
	init(_ parcel: AddBagViewModelParcel?) {
		self.parcel = parcel
	}
	
	func add() throws {
		guard let itemedPurchasable = itemedPurchasable else { return }
		try bagModelController.add(itemedPurchasable)
	}
	
	func favorite(for user: User) throws {
		guard let itemedPurchasable = itemedPurchasable else { return }
//		userAPIManager.add(PurchasableFavorite(itemedPurchasable), for: user)
//			.catch { print($0) }
	}
}
