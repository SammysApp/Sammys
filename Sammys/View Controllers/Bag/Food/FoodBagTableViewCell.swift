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
    
    // MARK: IBActions
    @IBAction func didTapEdit(_ sender: UIButton) {
        didEdit?(self)
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        didFave?(self)
    }
}
