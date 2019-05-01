//
//  OrderTableViewCell.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrderTableViewCell: StackTableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let dateLabel = UILabel()
    let pickupLabel = UILabel()
    
    let sideBar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.sideBarWidth/2
        return view
    }()
    
    private struct Constants {
        static let titleLabelFontSize = CGFloat(20)
        static let titleLabelFontWeight = UIFont.Weight.medium
        
        static let descriptionLabelFontSize = CGFloat(16)
        static let descriptionLabelFontWeight = UIFont.Weight.medium
        static let descriptionLabelTextColor = UIColor.lightGray
        
        static let dateLabelFontSize = CGFloat(16)
        static let dateLabelDefaultFontWeight = UIFont.Weight.medium
        static let dateLabelPickupDateFontWeight = UIFont.Weight.bold
        static let dateLabelDefaultTextColor = UIColor.lightGray
        static let dateLabelPickupDateTextColor = #colorLiteral(red: 1, green: 0, blue: 0.2615994811, alpha: 1)
        
        static let pickupLabelFontSize = CGFloat(12)
        static let pickupLabelFontWeight = UIFont.Weight.black
        static let pickupLabelTextColor = #colorLiteral(red: 1, green: 0, blue: 0.2615994811, alpha: 1)
        static let pickupLabelText = "PICKUP"
        
        static let sideBarWidth = CGFloat(8)
        static let sideBarSpacing = CGFloat(8)
        
        static let contentStackViewVerticalLayoutMargin = CGFloat(8)
        static let contentStackViewDefaultLeadingLayoutMargin = CGFloat(20)
        static let contentStackViewSideBarLeadingLayoutMargin = CGFloat(4)
        static let contentStackViewTrailingLayoutMargin = CGFloat(15)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        titleLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize, weight: Constants.titleLabelFontWeight)
        
        descriptionLabel.font = .systemFont(ofSize: Constants.descriptionLabelFontSize, weight: Constants.descriptionLabelFontWeight)
        descriptionLabel.textColor = Constants.descriptionLabelTextColor
        
        setUpForDefaultDate()
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        pickupLabel.font = .systemFont(ofSize: Constants.pickupLabelFontSize, weight: Constants.pickupLabelFontWeight)
        pickupLabel.textColor = Constants.pickupLabelTextColor
        pickupLabel.text = Constants.pickupLabelText
        pickupLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        sideBar.width(Constants.sideBarWidth)
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        leftStackView.axis = .vertical
        leftStackView.alignment = .leading
        
        let dateStackView = UIStackView(arrangedSubviews: [dateLabel, pickupLabel])
        dateStackView.axis = .vertical
        dateStackView.alignment = .center
        
        let rightStackView = UIStackView(arrangedSubviews: [dateStackView])
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        
        self.contentStackView.addArrangedSubview(sideBar)
        self.contentStackView.addArrangedSubview(leftStackView)
        self.contentStackView.addArrangedSubview(rightStackView)
        self.contentStackView.alignment = .center
        self.contentStackView.setCustomSpacing(Constants.sideBarSpacing, after: sideBar)
        self.contentStackView.isLayoutMarginsRelativeArrangement = true
        
        sideBar.topToSuperview(self.contentStackView.layoutMarginsGuide.topAnchor)
        sideBar.bottomToSuperview(self.contentStackView.layoutMarginsGuide.bottomAnchor)
    
        update()
    }
    
    private func update() {
        self.contentStackView.directionalLayoutMargins = .init(top: Constants.contentStackViewVerticalLayoutMargin, leading: sideBar.isHidden ? Constants.contentStackViewDefaultLeadingLayoutMargin : Constants.contentStackViewSideBarLeadingLayoutMargin, bottom: Constants.contentStackViewVerticalLayoutMargin, trailing: Constants.contentStackViewTrailingLayoutMargin)
    }
    
    func setUpForDefaultDate() {
        dateLabel.font = .systemFont(ofSize: Constants.dateLabelFontSize, weight: Constants.dateLabelDefaultFontWeight)
        dateLabel.textColor = Constants.dateLabelDefaultTextColor
        pickupLabel.isHidden = true
    }
    
    func setUpForPickupDate() {
        dateLabel.font = .systemFont(ofSize: Constants.dateLabelFontSize, weight: Constants.dateLabelPickupDateFontWeight)
        dateLabel.textColor = Constants.dateLabelPickupDateTextColor
        pickupLabel.isHidden = false
    }
    
    func showSideBar() {
        sideBar.isHidden = false
        update()
    }
    
    func hideSideBar() {
        sideBar.isHidden = true
        update()
    }
}
