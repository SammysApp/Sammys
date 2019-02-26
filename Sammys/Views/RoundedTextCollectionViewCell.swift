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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {
        self.addSubview(textLabel)
        textLabel.center(in: self.contentView)
        
        backgroundColor = .lightGray
    }
}
