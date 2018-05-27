//
//  ModifierCollectionViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ModifierCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateUI()
    }
    
    func updateUI() {
        contentView.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
}
