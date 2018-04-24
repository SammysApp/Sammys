//
//  TotalPriceTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum TotalPriceCellIdentifier: String {
    case totalCell
}

struct TotalPriceTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let order: Order
    let height: CGFloat
    
    func create() -> TableViewCellViewModel {
        return TableViewCellViewModel(identifier: TotalPriceCellIdentifier.totalCell.rawValue, height: height, commands: [.configuration: TotalPriceTableViewCellConfigurationCommand(order: order)])
    }
}
