//
//  ItemCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension BuilderViewModel {
	struct ItemCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
		let item: Item
		
		private struct Constants {
			static let cornerRadius: CGFloat = 20
		}
		
		func perform(parameters: CollectionViewCellCommandParameters) {
			guard let cell = parameters.cell as? ItemCollectionViewCell else { return }
			
			// Set style
			cell.layer.cornerRadius = Constants.cornerRadius
			cell.backgroundColor = .black
			
			// Set data
			cell.titleLabel.text = item.name
			if let pricedItem = item as? PricedItem {
				cell.priceLabel.text = "$\(pricedItem.price)"
			}
		}
	}
}
