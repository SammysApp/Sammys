//
//  RoundedTextCollectionViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class RoundedTextCollectionViewCell: UICollectionViewCell {
    let textLabel = UILabel()
    
    var cornerRadiusMultiplier: CGFloat = 0.2 {
        didSet { update() }
    }
    
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        self.addSubview(textLabel)
        textLabel.center(in: self.contentView)
        update()
    }
    
    private func update() {
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = self.frame.height * cornerRadiusMultiplier
    }
}
