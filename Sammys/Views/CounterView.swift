//
//  CounterView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CounterView: UIView {
    private var stackView = UIStackView()
    
    let counterTextField = UITextField()
    let decrementButton = RoundedButton()
    let incrementButton = RoundedButton()
    
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    convenience init() { self.init(frame: .zero) }
    
    private func setUp() {
        counterTextField.textAlignment = .center
        
        decrementButton.titleLabel.text = "-"
        incrementButton.titleLabel.text = "+"
        
        let stackViewViews = [decrementButton, counterTextField, incrementButton]
        stackViewViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview(view)
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        self.addSubview(stackView)
        stackView.edgesToSuperview()
    }
}
