//
//  HomePurchasableCategoryCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomePurchasableCategoryCollectionViewCellSelectionCommand: CollectionViewCellCommand {
	func perform(parameters: CollectionViewCellCommandParameters) {
		guard let homeViewController = parameters.viewController as? HomeViewController
			else { return }
	}
}
