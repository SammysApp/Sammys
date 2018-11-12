//
//  BagPurchasableTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol BagPurchasableTableViewCellDelegate {
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didChangeQuantityTo quantity: Int, at indexPath: IndexPath)
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didDecrementQuantityAt indexPath: IndexPath)
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didIncrementQuantityAt indexPath: IndexPath)
}

class BagPurchasableTableViewCell: UITableViewCell {
	var delegate: BagPurchasableTableViewCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet var purchasableImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
	@IBOutlet var quantityTextField: UITextField!
	
    // MARK: IBActions
    @IBAction func didTapEdit(_ sender: UIButton) {}
    @IBAction func didTapFave(_ sender: UIButton) {}
	
	@IBAction func quantityTextFieldDidChangeEditing(_ sender: UITextField) {
		guard let quantityString = sender.text,
			let quantity = Int(quantityString),
			let indexPath = indexPath else { return }
		delegate?.bagPurchasableTableViewCell(self, didChangeQuantityTo: quantity, at: indexPath)
	}
	
	@IBAction func didTapDecrement(_ sender: UIButton) {
		guard let indexPath = indexPath else { return }
		delegate?.bagPurchasableTableViewCell(self, didDecrementQuantityAt: indexPath)
	}
	
	@IBAction func didTapIncrement(_ sender: UIButton) {
		guard let indexPath = indexPath else { return }
		delegate?.bagPurchasableTableViewCell(self, didIncrementQuantityAt: indexPath)
	}
}
