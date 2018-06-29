//
//  NoteTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    private let textView = UITextView()
    private let placeholderTextView = UITextView()
    
    var textViewText: String {
        get {
            return textView.text
        } set {
            textView.text = newValue
            placeholderTextView.isHidden = !newValue.isEmpty
        }
    }
    
    var placeholderText = "" { didSet { updatePlaceholderTextViewUI() } }
    var fontSize: CGFloat = 16 { didSet { updateTextViewUI() } }
    var leftInset: CGFloat = 0 { didSet { updateTextViewConstraints() } }
    var didBeginEditingTextView: ((UITextView) -> Void)?
    var didEndEditingTextView: ((UITextView) -> Void)?
    var textViewDidChange: ((UITextView) -> Void)?
    
    var textViewConstraints: [NSLayoutConstraint] = [] {
        willSet {
            textViewConstraints.deactivateAll()
            newValue.activateAll()
        }
    }
    
    override var tintColor: UIColor! {
        get {
            return super.tintColor
        } set {
            super.tintColor = newValue
            updateTextViewUI()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updatePlaceholderTextViewUI()
    }
    
    func setup() {
        setupPlaceholderTextView()
        setupTextView()
    }
    
    func setupPlaceholderTextView() {
        addSubview(placeholderTextView)
        updatePlaceholderTextViewUI()
    }
    
    func setupTextView() {
        // General set up.
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        // Set up UI.
        textView.returnKeyType = .done
        updateTextViewUI()
    }
    
    func updatePlaceholderTextViewUI() {
        placeholderTextView.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        placeholderTextView.textContainer.lineFragmentPadding = 0
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.frame = textView.frame
        placeholderTextView.text = placeholderText
        placeholderTextView.textColor = .lightGray
        placeholderTextView.font = UIFont.systemFont(ofSize: fontSize)
        placeholderTextView.textAlignment = .left
        placeholderTextView.isUserInteractionEnabled = false
    }
    
    func updateTextViewUI() {
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.tintColor = tintColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        updateTextViewConstraints()
    }
    
    func updateTextViewConstraints() {
        textViewConstraints = textView.fullViewConstraints(equalTo: self, insetConstants: InsetConstants(left: leftInset, top: 0, right: 0, bottom: 0))
    }
}

extension NoteTableViewCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        didBeginEditingTextView?(textView)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewDidChange?(textView)
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Dismiss keyboard when typing enter.
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        didEndEditingTextView?(textView)
        return true
    }
}

