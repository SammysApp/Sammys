//
//  ProgressTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/2/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ProgressTableViewCell: StackTableViewCell {
    let circularImageView = UIImageView()
    let titleLabel = UILabel()
    let progressLabel = UILabel()
    
    private struct Constants {
        static let contentStackViewSpacing = CGFloat(15)
        static let contentStackViewVerticalLayoutMargin = CGFloat(20)
        static let contentStackViewHorizontalLayoutMargin = CGFloat(15)
        
        static let titleLabelFontSize = CGFloat(12)
        static let titleLabelFontWeight = UIFont.Weight.black
        static let titleLabelTextColor = UIColor.lightGray
        
        static let progressLabelFontSize = CGFloat(20)
        static let progressLabelFontWeight = UIFont.Weight.medium
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        update()
    }
    
    private func setUp() {
        circularImageView.contentMode = .center
        
        titleLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize, weight: Constants.titleLabelFontWeight)
        titleLabel.textColor = Constants.titleLabelTextColor
        
        progressLabel.font = .systemFont(ofSize: Constants.progressLabelFontSize, weight: Constants.progressLabelFontWeight)
        
        let rightStackView = UIStackView(arrangedSubviews: [titleLabel, progressLabel])
        rightStackView.axis = .vertical
        rightStackView.alignment = .leading
        
        self.contentStackView.addArrangedSubview(circularImageView)
        self.contentStackView.addArrangedSubview(rightStackView)
        self.contentStackView.alignment = .center
        self.contentStackView.spacing = Constants.contentStackViewSpacing
        self.contentStackView.directionalLayoutMargins = .init(top: Constants.contentStackViewVerticalLayoutMargin, leading: Constants.contentStackViewHorizontalLayoutMargin, bottom: Constants.contentStackViewVerticalLayoutMargin, trailing: Constants.contentStackViewHorizontalLayoutMargin)
        self.contentStackView.isLayoutMarginsRelativeArrangement = true
        
        circularImageView.topToSuperview(contentStackView.layoutMarginsGuide.topAnchor)
        circularImageView.bottomToSuperview(contentStackView.layoutMarginsGuide.bottomAnchor)
        circularImageView.widthToHeight(of: circularImageView)
        
        update()
    }
    
    private func update() {
        circularImageView.layer.cornerRadius = circularImageView.frame.height/2
    }
}
