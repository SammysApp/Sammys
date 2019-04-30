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
        static let priceLabelFontWeight = UIFont.Weight.semibold
        static let priceLabelFontSize = CGFloat(20)
        
        static let labelFontWeight = UIFont.Weight.bold
        static let labelFontSize = CGFloat(12)
        
        static let taxLabelText = "TAX"
        static let subtotalLabelText = "SUBTOTAL"
        
        static let priceStackViewInset = CGFloat(15)
        
        static let checkoutButtonBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        static let checkoutButtonTitleLabelTextColor = UIColor.white
        static let checkoutButtonTitleLabelFontWeight = UIFont.Weight.medium
        static let checkoutButtonTitleLabelFontSize = CGFloat(20)
        static let checkoutButtonTitleLabelDefaultText = "Checkout"
        static let checkoutButtonHeight = CGFloat(60)
        static let checkoutButtonInset = CGFloat(15)
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
        
        priceStackView.edgesToSuperview(excluding: .bottom, insets: .uniform(Constants.priceStackViewInset))
        
        checkoutButton.height(Constants.checkoutButtonHeight)
        checkoutButton.edgesToSuperview(excluding: .top, insets: .uniform(Constants.checkoutButtonInset))
        checkoutButton.topToBottom(of: priceStackView, relation: .equalOrGreater)
    }
    
    private func configurePriceStackView() {
        let taxStackView = UIStackView(arrangedSubviews: [taxPriceLabel, taxLabel])
        taxStackView.axis = .vertical
        taxStackView.alignment = .center
        
        let subtotalStackView = UIStackView(arrangedSubviews: [subtotalPriceLabel, subtotalLabel])
        subtotalStackView.axis = .vertical
        subtotalStackView.alignment = .center
        
        [taxStackView, subtotalStackView]
            .forEach { self.priceStackView.addArrangedSubview($0) }
        priceStackView.distribution = .fillEqually
    }
    
    private func configureTaxPriceLabel() {
        taxPriceLabel.textAlignment = .center
        taxPriceLabel.font = .systemFont(ofSize: Constants.priceLabelFontSize, weight: Constants.priceLabelFontWeight)
    }
    
    private func configureTaxLabel() {
        taxLabel.textAlignment = .center
        taxLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: Constants.labelFontWeight)
        taxLabel.text = Constants.taxLabelText
    }
    
    private func configureSubtotalPriceLabel() {
        subtotalPriceLabel.textAlignment = .center
        subtotalPriceLabel.font = .systemFont(ofSize: Constants.priceLabelFontSize, weight: Constants.priceLabelFontWeight)
    }
    
    private func configureSubtotalLabel() {
        subtotalLabel.textAlignment = .center
        subtotalLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: Constants.labelFontWeight)
        subtotalLabel.text = Constants.subtotalLabelText
    }
    
    private func configureCheckoutButton() {
        checkoutButton.backgroundColor = Constants.checkoutButtonBackgroundColor
        checkoutButton.titleLabel.textColor = Constants.checkoutButtonTitleLabelTextColor
        checkoutButton.titleLabel.font = .systemFont(ofSize: Constants.checkoutButtonTitleLabelFontSize, weight: Constants.checkoutButtonTitleLabelFontWeight)
        checkoutButton.add(checkoutButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func update() {
        updateCheckoutButton()
    }
    
    private func updateCheckoutButton() {
        checkoutButton.titleLabel.text = checkoutButtonTitleLabelText
    }
}
