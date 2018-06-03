//
//  OrderTableViewCellViewModelFactory.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum OrderCellIdentifier: String {
    case orderCell
}

struct OrderTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let kitchenOrder: KitchenOrder
    
    func create() -> TableViewCellViewModel {
        return DefaultTableViewCellViewModel(identifier: OrderCellIdentifier.orderCell.rawValue, height: 80, commands: [.configuration: OrderTableViewCellConfigurationCommand(kitchenOrder: kitchenOrder)])
    }
}
