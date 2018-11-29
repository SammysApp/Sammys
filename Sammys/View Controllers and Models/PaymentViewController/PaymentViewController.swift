//
//  PaymentViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol PaymentViewControllerDelegate {
	func paymentViewController(_ paymentViewController: PaymentViewController, didTapPayButton button: UIButton)
}

class PaymentViewController: UIViewController, Delegatable {
	var viewModelParcel: PaymentViewModelParcel?
	{ didSet { viewModel.parcel = viewModelParcel ; loadViews() } }
	lazy var viewModel = PaymentViewModel(viewModelParcel)
	
	var delegate: PaymentViewControllerDelegate?
	
	// MARK: IBOutlets
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var taxLabel: UILabel!
	@IBOutlet var payButton: UIButton!
	
	struct Constants {
		static let payButtonCornerRadius: CGFloat = 20
	}
	
	// MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupPayButton()
		loadViews()
	}
	
	func setupPayButton() {
		payButton.layer.cornerRadius = Constants.payButtonCornerRadius
	}
	
	// MARK: - Load
	func loadViews() {
		subtotalLabel?.text = viewModel.subtotalText
		taxLabel?.text = viewModel.taxText
		payButton?.setTitle(viewModel.payText, for: .normal)
	}
	
	// MARK: - IBActions
	@IBAction func didTapPayButton(_ sender: UIButton) { delegate?.paymentViewController(self, didTapPayButton: sender) }
}

// MARK: - Storyboardable
extension PaymentViewController: Storyboardable {}
