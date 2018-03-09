//
//  ItemTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    var edit: ((ItemTableViewCell) -> Void)?
    var fave: ((ItemTableViewCell) -> Void)?
    
    // MARK: IBOutlets
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
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
    @IBAction func edit(_ sender: UIButton) {
        edit?(self)
    }
    
    @IBAction func fave(_ sender: UIButton) {
        fave?(self)
    }
}
