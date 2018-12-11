//
//  HomePurchasableCategoryCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableCategoryCollectionViewCellSelectionCommand: CollectionViewCellCommand {
	let category: PurchasableCategoryNode
	
	func perform(parameters: CollectionViewCellCommandParameters) {
		guard let homeViewController = parameters.viewController as? HomeViewController
			else { return }
		if let next = category.next {
			switch next {
			case .categories(let categories):
				let purchasableCategoriesViewController = PurchasableCategoriesViewController.storyboardInstance()
				purchasableCategoriesViewController.viewModelParcel = PurchasableCategoriesViewModelParcel(categories: categories)
				homeViewController.navigationController?.pushViewController(purchasableCategoriesViewController, animated: true)
			default: break
			}
		}
	}
}
