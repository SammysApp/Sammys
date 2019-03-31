//
//  CheckoutSheetViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CheckoutSheetViewController: UIViewController {
    let priceStackView = UIStackView()
    let taxPriceLabel = UILabel()
    let taxLabel = UILabel()
    let subtotalPriceLabel = UILabel()
    let subtotalLabel = UILabel()
    let checkoutButton = RoundedButton()
    
    private lazy var checkoutButtonTouchUpInsideTarget = Target(action: checkoutButtonTouchUpInsideHandler)
    
    var checkoutButtonTitleLabelText = Constants.checkoutButtonTitleLabelDefaultText {
        didSet { update() }
    }
    var checkoutButtonTouchUpInsideHandler: () -> Void = {} {
        didSet { checkoutButtonTouchUpInsideTarget.action = checkoutButtonTouchUpInsideHandler  }
    }
    
    private struct Constants {
        static let taxLabelText = "TAX"
        static let subtotalLabelText = "SUBTOTAL"
        static let checkoutButtonTitleLabelDefaultText = "Checkout"
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
        configureCheckoutButton()
        configurePriceStackView()
        setUpView()
        update()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [priceStackView, checkoutButton]
            .forEach { self.view.addSubview($0) }
        priceStackView.edgesToSuperview(excluding: .bottom)
        checkoutButton.edgesToSuperview(excluding: .top)
        checkoutButton.topToBottom(of: priceStackView)
    }
    
    private func configurePriceStackView() {
        let taxStackView = UIStackView(arrangedSubviews: [taxPriceLabel, taxLabel])
        taxStackView.axis = .vertical
        
        let subtotalStackView = UIStackView(arrangedSubviews: [subtotalPriceLabel, subtotalLabel])
        subtotalStackView.axis = .vertical
        
        [taxStackView, subtotalStackView]
            .forEach { self.priceStackView.addArrangedSubview($0) }
        priceStackView.distribution = .fillEqually
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
    
    private func configureCheckoutButton() {
        checkoutButton.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        checkoutButton.titleLabel.textColor = .white
        checkoutButton.add(checkoutButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func update() {
        updateCheckoutButton()
    }
    
    private func updateCheckoutButton() {
        checkoutButton.titleLabel.text = checkoutButtonTitleLabelText
    }
}
