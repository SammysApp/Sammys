//
//  ItemCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension ItemsViewModel {
	struct ItemCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
		let item: Item
		
		private struct Constants {
			static let cornerRadius: CGFloat = 20
		}
		
		func perform(parameters: CollectionViewCellCommandParameters) {
			guard let cell = parameters.cell as? ItemCollectionViewCell else { return }
			cell.layer.cornerRadius = Constants.cornerRadius
			cell.backgroundColor = .black
			cell.titleLabel.text = item.name
//			if let pricedItem = item as? PricedItem {
//				cell.priceLabel.text = pricedItem.price.priceString
//			}
		}
	}
}
