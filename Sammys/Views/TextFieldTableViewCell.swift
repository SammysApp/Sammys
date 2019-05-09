//
//  TextFieldTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: StackTableViewCell {
    let titleLabel = UILabel()
    let textField = UITextField()
    
    var titleLabelWidth = CGFloat(0) {
        didSet { update() }
    }
    var textFieldTextUpdateHandler: (String?) -> Void = { _ in }
    
    private var titleLabelWidthConstraint: NSLayoutConstraint?
    
    private lazy var textFieldEditingChangedTarget = Target { self.textFieldTextUpdateHandler(self.textField.text) }
    
    private struct Constants {
        static let contentStackViewSpacing = CGFloat(10)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        titleLabel.textAlignment = .right
        textField.add(textFieldEditingChangedTarget, for: .editingChanged)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textField)
        contentStackView.spacing = Constants.contentStackViewSpacing
        
        update()
    }
    
    private func update() {
        if let constraint = titleLabelWidthConstraint {
            titleLabel.removeConstraint(constraint)
        }
        titleLabelWidthConstraint = titleLabel.width(titleLabelWidth)
    }
}
