//
//  DetailTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum DetailCellIdentifier: String {
    case detailCell
}

struct DetailTableViewCellViewModelFactory/*: TableViewCellViewModelFactory*/ {
    let height: CGFloat
    let titleText: String
    let detailText: String
    
//    func create() -> TableViewCellViewModel {
//        let configurationCommand = DetailTableViewCellConfigurationCommand(titleText: titleText, detailText: detailText)
//		return DefaultTableViewCellViewModel(identifier: DetailCellIdentifier.detailCell.rawValue, height: height, commands: [:])
//    }
}
