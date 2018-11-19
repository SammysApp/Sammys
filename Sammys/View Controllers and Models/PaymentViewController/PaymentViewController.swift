//
//  PaymentViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol PaymentViewControllerDelegate {
	func paymentViewController(_ paymentViewController: PaymentViewController, didTapPay payButton: UIButton, forTotal total: Double)
}

class PaymentViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: PaymentViewModelParcel! {
		didSet { viewModel = PaymentViewModel(viewModelParcel) }
	}
	private var viewModel: PaymentViewModel! { didSet { loadViews() } }
	
	var delegate: PaymentViewControllerDelegate?
	
	// MARK: IBOutlets
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var taxLabel: UILabel!
	@IBOutlet var payButton: UIButton!
	
	struct Constants {
		static let totalButtonCornerRadius: CGFloat = 20
	}
	
	// MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	func loadViews() {
		subtotalLabel?.text = viewModel.subtotalText
		taxLabel?.text = viewModel.taxText
		payButton?.setTitle(viewModel.payText, for: .normal)
	}
	
	// MARK: - Setup
	func setupViews() {
		setupTotalButton()
		loadViews()
	}
	
	func setupTotalButton() {
		payButton.layer.cornerRadius = Constants.totalButtonCornerRadius
	}
	
	// MARK: - IBActions
	@IBAction func didTapPayButton(_ sender: UIButton) { delegate?.paymentViewController(self, didTapPay: sender, forTotal: viewModel.total) }
}

// MARK: - Storyboardable
extension PaymentViewController: Storyboardable {}
