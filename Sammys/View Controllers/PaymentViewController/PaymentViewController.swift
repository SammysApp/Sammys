//
//  PaymentViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
	// MARK: IBOutlets
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var taxLabel: UILabel!
	@IBOutlet var totalButton: UIButton!
	
	struct Constants {
		static let totalButtonCornerRadius: CGFloat = 20
	}
	
	// MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupTotalButton()
	}
	
	func setupTotalButton() {
		totalButton.layer.cornerRadius = Constants.totalButtonCornerRadius
	}
	
	// MARK: - IBActions
	@IBAction func didTapTotalButton(_ sender: UIButton) {
	}
}

// MARK: - Storyboardable
extension PaymentViewController: Storyboardable {}
