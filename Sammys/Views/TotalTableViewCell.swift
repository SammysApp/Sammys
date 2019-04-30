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
    
    private let subtotalStackView = UIStackView()
    private let taxStackView = UIStackView()
    private let totalStackView = UIStackView()
    
    private struct Constants {
        static let priceLabelsFontWeight = UIFont.Weight.medium
        static let priceLabelsFontSize = CGFloat(22)
        
        static let labelsFontWeight = UIFont.Weight.semibold
        static let labelsFontSize = CGFloat(12)
        
        static let subtotalLabelText = "SUBTOTAL"
        static let taxLabelText = "TAX"
        
        static let totalPriceLabelFontWeight = UIFont.Weight.bold
        static let totalLabelFontWeight = UIFont.Weight.heavy
        static let totalLabelText = "TOTAL"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        [subtotalPriceLabel, taxPriceLabel]
            .forEach { $0.font = .systemFont(ofSize: Constants.priceLabelsFontSize, weight: Constants.priceLabelsFontWeight) }
        
        [subtotalLabel, taxLabel]
            .forEach { $0.font = .systemFont(ofSize: Constants.labelsFontSize, weight: Constants.labelsFontWeight) }
        subtotalLabel.text = Constants.subtotalLabelText
        taxLabel.text = Constants.taxLabelText
        
        totalPriceLabel.font = .systemFont(ofSize: Constants.priceLabelsFontSize, weight: Constants.totalPriceLabelFontWeight)
        totalLabel.font = .systemFont(ofSize: Constants.labelsFontSize, weight: Constants.totalLabelFontWeight)
        totalLabel.text = Constants.totalLabelText
        
        [subtotalPriceLabel, subtotalLabel]
            .forEach { self.subtotalStackView.addArrangedSubview($0) }
        subtotalStackView.axis = .vertical
        subtotalStackView.alignment = .center
        
        [taxPriceLabel, taxLabel]
            .forEach { self.taxStackView.addArrangedSubview($0) }
        taxStackView.axis = .vertical
        taxStackView.alignment = .center
        
        [totalPriceLabel, totalLabel]
            .forEach { self.totalStackView.addArrangedSubview($0) }
        totalStackView.axis = .vertical
        totalStackView.alignment = .center
        
        [subtotalStackView, taxStackView, totalStackView]
            .forEach { self.contentStackView.addArrangedSubview($0) }
        self.contentStackView.distribution = .fillEqually
        self.contentStackView.alignment = .center
    }
}
