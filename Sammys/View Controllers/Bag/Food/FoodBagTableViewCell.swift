//
//  FoodBagTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodBagTableViewCell: UITableViewCell {
    var didEdit: ((FoodBagTableViewCell) -> Void)?
    var didFave: ((FoodBagTableViewCell) -> Void)?
    
    // MARK: IBOutlets
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityCollectionView: QuantityCollectionView!
    
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
        
        setup()
    }
    
    func setup() {
        if itemImageView != nil {
            itemImageView.layer.cornerRadius = itemImageView!.frame.width/2
        }
    }
    
    // MARK: IBActions
    @IBAction func didTapEdit(_ sender: UIButton) {
        didEdit?(self)
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        didFave?(self)
    }
}
