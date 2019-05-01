//
//  ItemTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/15/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemTableViewCell: StackTableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let priceLabel = UILabel()
    let quantityView = CounterView()
    
    var quantityViewButtonsBackgroundColor = UIColor.lightGray {
        didSet { update() }
    }
    var quantityViewButtonsImageColor = UIColor.black {
        didSet { update() }
    }
    
    var quantityViewTextFieldTextUpdateHandler: (CounterView) -> Void = { _ in } {
        didSet {
            quantityViewTextFieldEditingChangedTarget.action = { self.quantityViewTextFieldTextUpdateHandler(self.quantityView) }
        }
    }
    
    var quantityViewDidDecrementHandler: (CounterView) -> Void = { _ in } {
        didSet {
            quantityViewDecrementButtonTouchUpInsideTarget.action =
                { self.quantityViewDidDecrementHandler(self.quantityView) }
        }
    }
    var quantityViewDidIncrementHandler: (CounterView) -> Void = { _ in } {
        didSet {
            quantityViewIncrementButtonTouchUpInsideTarget.action =
                { self.quantityViewDidIncrementHandler(self.quantityView) }
        }
    }
    
    private lazy var quantityViewTextFieldEditingChangedTarget = Target { self.quantityViewTextFieldTextUpdateHandler(self.quantityView) }
    
    private lazy var quantityViewDecrementButtonTouchUpInsideTarget =
        Target { self.quantityViewDidDecrementHandler(self.quantityView) }
    private lazy var quantityViewIncrementButtonTouchUpInsideTarget =
        Target { self.quantityViewDidIncrementHandler(self.quantityView) }
    
    private struct Constants {
        static let quantityViewHeight = CGFloat(40)
        
        static let contentStackViewSpacing = CGFloat(5)
        
        static let contentStackViewVerticalLayoutMargin = CGFloat(10)
        static let contentStackViewHorizontalLayoutMargin = CGFloat(15)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        descriptionLabel.numberOfLines = 0
        
        quantityView.height(Constants.quantityViewHeight)
        quantityView.counterTextField.add(quantityViewTextFieldEditingChangedTarget, for: .editingChanged)
        quantityView.decrementButton.add(quantityViewDecrementButtonTouchUpInsideTarget, for: .touchUpInside)
        quantityView.incrementButton.add(quantityViewIncrementButtonTouchUpInsideTarget, for: .touchUpInside)
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        leftStackView.axis = .vertical
        
        let rightStackView = UIStackView(arrangedSubviews: [priceLabel])
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        
        let splitStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        
        self.contentStackView.axis = .vertical
        self.contentStackView.spacing = Constants.contentStackViewSpacing
        self.contentStackView.directionalLayoutMargins = .init(top: Constants.contentStackViewVerticalLayoutMargin, leading: Constants.contentStackViewHorizontalLayoutMargin, bottom: Constants.contentStackViewVerticalLayoutMargin, trailing: Constants.contentStackViewHorizontalLayoutMargin)
        self.contentStackView.isLayoutMarginsRelativeArrangement = true
        self.contentStackView.addArrangedSubview(splitStackView)
        self.contentStackView.addArrangedSubview(quantityView)
        
        update()
    }
    
    private func update() {
        quantityView.buttonsBackgroundColor = quantityViewButtonsBackgroundColor
        quantityView.buttonsImageColor = quantityViewButtonsImageColor
    }
}
