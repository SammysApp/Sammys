//
//  BagFoodTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class BagFoodTableViewCell: UITableViewCell {
    var didEdit: ((BagFoodTableViewCell) -> Void)?
    var didFave: ((BagFoodTableViewCell) -> Void)?
    
    // MARK: IBOutlets
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func didTapEdit(_ sender: UIButton) {
        didEdit?(self)
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        didFave?(self)
    }
}
