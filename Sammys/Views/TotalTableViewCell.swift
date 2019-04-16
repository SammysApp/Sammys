//
//  TotalTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/15/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class TotalTableViewCell: StackTableViewCell {
    let subtotalPriceLabel = UILabel()
    let subtotalLabel = UILabel()
    let taxPriceLabel = UILabel()
    let taxLabel = UILabel()
    let totalPriceLabel = UILabel()
    let totalLabel = UILabel()
    
    private let leftStackView = UIStackView()
    private let rightStackView = UIStackView()
    
    private struct Constants {
        static let priceLabelsFontWeight = UIFont.Weight.semibold
        static let priceLabelsFontSize = CGFloat(20)
        
        static let labelsFontWeight = UIFont.Weight.bold
        static let labelsFontSize = CGFloat(12)
        
        static let subtotalLabelText = "SUBTOTAL"
        static let taxLabelText = "TAX"
        
        static let totalPriceLabelFontSize = CGFloat(32)
        static let totalText = "TOTAL"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        [subtotalLabel, taxLabel, totalLabel]
            .forEach { $0.font = .systemFont(ofSize: Constants.labelsFontSize, weight: Constants.labelsFontWeight) }
        [subtotalPriceLabel, taxPriceLabel]
            .forEach { $0.font = .systemFont(ofSize: Constants.priceLabelsFontSize, weight: Constants.priceLabelsFontWeight) }
        subtotalLabel.text = Constants.subtotalLabelText
        taxLabel.text = Constants.taxLabelText
        totalLabel.text = Constants.totalText
        
        totalPriceLabel.font = .systemFont(ofSize: Constants.totalPriceLabelFontSize, weight: Constants.priceLabelsFontWeight)
        
        [subtotalPriceLabel, subtotalLabel, taxPriceLabel, taxLabel]
            .forEach { self.leftStackView.addArrangedSubview($0) }
        leftStackView.axis = .vertical
        
        [totalPriceLabel, totalLabel]
            .forEach { self.rightStackView.addArrangedSubview($0) }
        rightStackView.axis = .vertical
        
        [leftStackView, rightStackView]
            .forEach { self.contentStackView.addArrangedSubview($0) }
    }
}
