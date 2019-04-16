//
//  ItemTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/15/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemTableViewCell: StackTableViewCell {
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let priceLabel = UILabel()
    let quantityView = CounterView()
    
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
    
    private lazy var quantityViewDecrementButtonTouchUpInsideTarget =
        Target { self.quantityViewDidDecrementHandler(self.quantityView) }
    private lazy var quantityViewIncrementButtonTouchUpInsideTarget =
        Target { self.quantityViewDidIncrementHandler(self.quantityView) }
    
    private struct Constants {
        static let nameLabelDefaultText = "Name"
        static let descriptionLabelDefaultText = "Description"
        
        static let quantityViewHeight = CGFloat(40)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        nameLabel.text = Constants.nameLabelDefaultText
        descriptionLabel.text = Constants.descriptionLabelDefaultText
        descriptionLabel.numberOfLines = 0
        
        quantityView.height(Constants.quantityViewHeight)
        quantityView.decrementButton.add(quantityViewDecrementButtonTouchUpInsideTarget, for: .touchUpInside)
        quantityView.incrementButton.add(quantityViewIncrementButtonTouchUpInsideTarget, for: .touchUpInside)
        
        let leftStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        leftStackView.axis = .vertical
        
        let rightStackView = UIStackView(arrangedSubviews: [priceLabel])
        rightStackView.axis = .vertical
        
        let splitStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        
        self.contentStackView.axis = .vertical
        self.contentStackView.addArrangedSubview(splitStackView)
        self.contentStackView.addArrangedSubview(quantityView)
    }
}
