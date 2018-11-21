//
//  HomePurchasableTypeCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct HomePurchasableTypeCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    let purchasableType: Purchasable.Type
    
    private struct Constants {
        static let cornerRadius: CGFloat = 20
        static let shadowOpacity: Float = 0.2
    }
    
    func perform(parameters: CollectionViewCellCommandParameters) {
        guard let cell = parameters.cell as? HomePurchasableTypeCollectionViewCell else { return }
		
        cell.titleLabel.text = purchasableType.title
		
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = Constants.cornerRadius
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.masksToBounds = false
        cell.add(
			UIView.Shadow(
				path: UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath,
				opacity: Constants.shadowOpacity
			)
		)
    }
}
