//
//  QuantityCollectionViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class QuantityCollectionViewCell: UICollectionViewCell {
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var deleteImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateUI()
    }
    
    func updateUI() {
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
}
