//
//  OrderCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    let order: Order
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? OrderCollectionViewCell else { return }
        cell.orderLabel.text = order.number
        cell.dateLabel.text = order.date.description
    }
}
