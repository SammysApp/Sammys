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
    var textViewDidChange: ((UITextView) -> Void)?
    
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
        addSubview(textView)
        
        // Set up UI.
        textView.fullViewConstraint(equalToMarginOf: self)
        updateTextViewUI()
    }
    
    func updatePlaceholderTextViewUI() {
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.frame = textView.frame
        placeholderTextView.text = placeholderText
        placeholderTextView.textColor = .lightGray
        placeholderTextView.font = UIFont.systemFont(ofSize: fontSize)
        placeholderTextView.textAlignment = .left
        placeholderTextView.isUserInteractionEnabled = false
    }
    
    func updateTextViewUI() {
        textView.backgroundColor = .clear
        textView.tintColor = tintColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textAlignment = .left
        textView.isScrollEnabled = false
    }
}

extension NoteTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewDidChange?(textView)
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
}
