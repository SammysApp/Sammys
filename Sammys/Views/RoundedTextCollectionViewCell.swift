//
//  RoundedTextCollectionViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class RoundedTextCollectionViewCell: UICollectionViewCell {
    let textLabel = UILabel()
    
    var cornerRadiusMultiplier = CGFloat(0.2) {
        didSet { update() }
    }
    
    private struct Constants {
        static let textLabelInset = CGFloat(10)
    }
    
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        self.addSubview(textLabel)
        textLabel.edgesToSuperview(insets: .uniform(Constants.textLabelInset))
        
        update()
    }
    
    private func update() {
        self.layer.cornerRadius = self.frame.height * cornerRadiusMultiplier
    }
}
