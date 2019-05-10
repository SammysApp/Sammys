//
//  TextViewTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/9/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class TextViewTableViewCell: UITableViewCell {
    let placeholderLabel = UILabel()
    let textView = UITextView()
    
    var textViewLeadingOffset = CGFloat(0) {
        didSet { update() }
    }
    
    private var textViewLeadingConstraint: Constraint?
    
    var textViewTextDidChangeHandler: (String) -> Void = { _ in }
    
    private struct Constants {
        static let textViewMinimumVerticalOffset = CGFloat(10)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func set(textViewText text: String) {
        self.textView.text = text
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func setUp() {
        textView.backgroundColor = .clear
        textView.textContainerInset = .init(top: 0, left: -5, bottom: 0, right: 0)
        textView.delegate = self
        
        self.addSubview(placeholderLabel)
        self.addSubview(textView)
        
        textView.topToSuperview(offset: Constants.textViewMinimumVerticalOffset, relation: .equalOrGreater)
        textView.trailingToSuperview()
        textView.bottomToSuperview(offset: -Constants.textViewMinimumVerticalOffset, relation: .equalOrLess)
        textView.centerYToSuperview()
        
        placeholderLabel.centerY(to: textView)
        placeholderLabel.leading(to: textView)
        
        update()
    }
    
    private func update() {
        if let textViewLeadingConstraint = textViewLeadingConstraint {
            textView.removeConstraint(textViewLeadingConstraint)
        }
        textViewLeadingConstraint = textView.leadingToSuperview(offset: textViewLeadingOffset)
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textViewTextDidChangeHandler(textView.text)
    }
}
