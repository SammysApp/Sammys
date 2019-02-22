//
//  HomeViewController+ImageTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

extension HomeViewController {
    struct ImageTableViewCellConfigurationData {
        let text: String
    }
    
    struct ImageTableViewCellConfiguration: TableViewCellCommand {
        let data: ImageTableViewCellConfigurationData
        
        func perform(cell: UITableViewCell?) {
            guard let cell = cell as? ImageTableViewCell else { return }
            cell.textLabel.text = data.text
        }
    }
}
