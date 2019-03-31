//
//  CheckoutSheetViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CheckoutSheetViewController: UIViewController {
    let taxPriceLabel = UILabel()
    let taxLabel = UILabel()
    let subtotalPriceLabel = UILabel()
    let subtotalLabel = UILabel()
    let checkoutButton = UIButton()
    
    private struct Constants {
        static let taxLabelText = "TAX"
        static let subtotalLabelText = "SUBTOTAL"
        static let priceLabelFontSize: CGFloat = 20
        static let labelFontSize: CGFloat = 12
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTaxPriceLabel()
        configureTaxLabel()
        configureSubtotalPriceLabel()
        configureSubtotalLabel()
        setUpView()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        let taxStackView = UIStackView(arrangedSubviews: [taxPriceLabel, taxLabel])
        taxStackView.axis = .vertical
        
        let subtotalStackView = UIStackView(arrangedSubviews: [subtotalPriceLabel, subtotalLabel])
        subtotalStackView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [taxStackView, subtotalStackView])
        stackView.distribution = .fillEqually
        self.view.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    private func configureTaxPriceLabel() {
        taxPriceLabel.textAlignment = .center
        taxPriceLabel.font = .systemFont(ofSize: Constants.priceLabelFontSize, weight: .semibold)
    }
    
    private func configureTaxLabel() {
        taxLabel.textAlignment = .center
        taxLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .bold)
        taxLabel.text = Constants.taxLabelText
    }
    
    private func configureSubtotalPriceLabel() {
        subtotalPriceLabel.textAlignment = .center
        subtotalPriceLabel.font = .systemFont(ofSize: Constants.priceLabelFontSize, weight: .semibold)
    }
    
    private func configureSubtotalLabel() {
        subtotalLabel.textAlignment = .center
        subtotalLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .bold)
        subtotalLabel.text = Constants.subtotalLabelText
    }
}
