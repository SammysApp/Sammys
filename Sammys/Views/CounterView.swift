//
//  CounterView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CounterView: UIView {
    let counterTextField = UITextField()
    let decrementButton = RoundedButton()
    let incrementButton = RoundedButton()
    
    private var stackView = UIStackView()
    
    var buttonsBackgroundColor = UIColor.lightGray {
        didSet { update() }
    }
    var buttonsImageColor = UIColor.black {
        didSet { update() }
    }
    
    private struct Constants {
        static let decrementButtonImage = #imageLiteral(resourceName: "CounterView.Minus")
        static let incrementButtonImage = #imageLiteral(resourceName: "CounterView.Plus")
    }
    
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    convenience init() { self.init(frame: .zero) }
    
    private func setUp() {
        counterTextField.textAlignment = .center
        
        decrementButton.imageView.image = Constants.decrementButtonImage
        incrementButton.imageView.image = Constants.incrementButtonImage
        
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
        
        update()
    }
    
    private func update() {
        [decrementButton, incrementButton].forEach { button in
            button.backgroundColor = buttonsBackgroundColor
            button.imageView.tintColor = buttonsImageColor
        }
    }
}
