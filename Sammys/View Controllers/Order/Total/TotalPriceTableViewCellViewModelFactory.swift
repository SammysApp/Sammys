//
//  TotalPriceTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct TotalPriceTableViewCellViewModel: TableViewCellViewModel {
    let order: Order
    let identifier: String
    let height: CGFloat
    let commands: [TableViewCommandActionKey : TableViewCellCommand]
}

enum TotalPriceCellIdentifier: String {
    case totalCell
}

struct TotalPriceTableViewCellViewModelFactory/*: TableViewCellViewModelFactory*/ {
//    let order: Order
//    let height: CGFloat
//
//    func create() -> TableViewCellViewModel {
//        return TotalPriceTableViewCellViewModel(order: order, identifier: TotalPriceCellIdentifier.totalCell.rawValue, height: height, commands: [.configuration: TotalPriceTableViewCellConfigurationCommand(order: order)])
//    }
}
