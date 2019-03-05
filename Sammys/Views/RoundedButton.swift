//
//  RoundedButton.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/5/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class RoundedButton: UIControl {
    let titleLabel = UILabel()
    
    private let roundedLayer = CAShapeLayer()
    
    var cornerRadiusMultiplier: CGFloat = 0.2 {
        didSet { update() }
    }
    
    private struct Constants {
        static let titleLabelInset: CGFloat = 10
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    private override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    func setUp() {
        self.layer.addSublayer(roundedLayer)
        [titleLabel]
            .forEach { self.addSubview($0) }
        titleLabel.center(in: self)
        titleLabel.left(to: self, offset: Constants.titleLabelInset, priority: .required)
        titleLabel.right(to: self, offset: -Constants.titleLabelInset, priority: .required)
    }
    
    func update() {
        roundedLayer.fillColor = UIColor.lightGray.cgColor
        roundedLayer.path = UIBezierPath(roundedRect: .init(x: 0, y: 0, width: titleLabel.frame.width + (Constants.titleLabelInset * 2), height: self.frame.height), cornerRadius: self.frame.height * cornerRadiusMultiplier).cgPath
    }
}
