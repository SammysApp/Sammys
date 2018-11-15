//
//  DetailTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct DetailTableViewCellConfigurationCommand: TableViewCellCommand {
	let titleText: String
    let detailText: String
    
    func perform(parameters: TableViewCellCommandParameters) {
        guard let cell = parameters.cell else { return }
        cell.textLabel?.text = titleText
        cell.detailTextLabel?.text = detailText
    }
}
