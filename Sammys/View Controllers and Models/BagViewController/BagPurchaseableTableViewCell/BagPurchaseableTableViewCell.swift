//
//  BagPurchaseableTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol BagPurchaseableTableViewCellDelegate {
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didChangeQuantityTo quantity: Int, at indexPath: IndexPath)
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didDecrementQuantityAt indexPath: IndexPath)
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didIncrementQuantityAt indexPath: IndexPath)
}

class BagPurchaseableTableViewCell: UITableViewCell {
	var delegate: BagPurchaseableTableViewCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet var purchaseableImageView: UIImageView!
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
		delegate?.bagPurchaseableTableViewCell(self, didChangeQuantityTo: quantity, at: indexPath)
	}
	
	@IBAction func didTapDecrement(_ sender: UIButton) {
		guard let indexPath = indexPath else { return }
		delegate?.bagPurchaseableTableViewCell(self, didDecrementQuantityAt: indexPath)
	}
	
	@IBAction func didTapIncrement(_ sender: UIButton) {
		guard let indexPath = indexPath else { return }
		delegate?.bagPurchaseableTableViewCell(self, didIncrementQuantityAt: indexPath)
	}
}
