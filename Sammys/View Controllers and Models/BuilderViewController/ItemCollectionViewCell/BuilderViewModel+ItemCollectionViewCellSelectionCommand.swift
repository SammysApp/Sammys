//
//  BuilderViewModel+ItemCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension BuilderViewModel {
	struct ItemCollectionViewCellSelectionCommand: CollectionViewCellCommand {
		let item: Item
		
		func perform(parameters: CollectionViewCellCommandParameters) {
			guard let builderViewController = parameters.viewController as? BuilderViewController else { return }
			do { try builderViewController.viewModel.toggle(item) } catch { print(error) }
		}
	}
}
