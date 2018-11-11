//
//  ButtonTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ButtonTableViewCellConfigurationCommand/*: TableViewCellCommand*/ {
    let buttonText: String
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell else { return }
        cell.textLabel?.text = buttonText
    }
}