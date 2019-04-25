//
//  OrderTableViewCell.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrderTableViewCell: StackTableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let pickupDateLabel = UILabel()
    let pickupLabel = UILabel()
    
    private(set) lazy var pickupStackView = UIStackView(arrangedSubviews: [pickupDateLabel, pickupLabel])
    
    private struct Constants {
        static let pickupLabelText = "PICKUP"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setUp() {
        pickupLabel.text = Constants.pickupLabelText
        pickupStackView.axis = .vertical
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        let splitStackView = UIStackView(arrangedSubviews: [leftStackView, pickupStackView])
        contentStackView.addArrangedSubview(splitStackView)
    }
}
