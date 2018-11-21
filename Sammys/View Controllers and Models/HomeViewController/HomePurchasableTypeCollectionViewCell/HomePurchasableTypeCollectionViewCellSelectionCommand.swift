//
//  HomePurchasableTypeCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableTypeCollectionViewCellSelectionCommand: CollectionViewCellCommand {
	let purchasableType: Purchasable.Type
	
	func perform(parameters: CollectionViewCellCommandParameters) {
		guard let homeViewController = parameters.viewController as? HomeViewController
			else { return }
		if let itemedPurchasableType = purchasableType as? ItemedPurchasable.Type {
			homeViewController.builderViewController.viewModelParcel = BuilderViewModelParcel.instance(for: itemedPurchasableType)
			if homeViewController.isVisible { homeViewController.navigationController?.pushViewController(homeViewController.builderViewController, animated: true) }
		}
	}
}
