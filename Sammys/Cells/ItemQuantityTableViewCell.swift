//
//  ItemQuantityTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemQuantityTableViewCell: UITableViewCell {
    @IBOutlet var quantityCollectionView: QuantityCollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        
    }
}
