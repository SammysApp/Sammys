//
//  OrderTableViewCellConfigurationCommand.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderTableViewCellConfigurationCommand: TableViewCellCommand {
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? OrderTableViewCell else { return }
        cell.numberLabel.text = "#2"
    }
}
