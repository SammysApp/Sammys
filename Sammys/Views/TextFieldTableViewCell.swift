//
//  TextFieldTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let textField = UITextField()
    
    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
    private var titleLabelWidthConstraint: NSLayoutConstraint?
    private lazy var textFieldEditingChangedTarget = Target { self.textFieldTextUpdateHandler(self.textField.text) }
    
    var titleLabelWidth: CGFloat = 0 {
        didSet { update() }
    }
    var textFieldTextUpdateHandler: (String?) -> Void = { _ in }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        titleLabel.textAlignment = .right
        
        textField.add(textFieldEditingChangedTarget, for: .editingChanged)
        
        self.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    private func update() {
        if let constraint = titleLabelWidthConstraint {
            titleLabel.removeConstraint(constraint)
        }
        titleLabelWidthConstraint = titleLabel.width(titleLabelWidth)
    }
}
