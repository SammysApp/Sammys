//
//  SubtitleTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/27/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
