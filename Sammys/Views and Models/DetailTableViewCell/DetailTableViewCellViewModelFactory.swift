//
//  DetailTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct DetailTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let identifier: String
    let height: Double
    
    let titleText: String
    let detailText: String
    
    func create() -> BasicTableViewCellViewModel {
        let configuration = DetailTableViewCellConfigurationCommand(titleText: titleText, detailText: detailText)
        return BasicTableViewCellViewModel(
            identifier: identifier,
            height: height,
            commands: [.configuration: configuration]
        )
    }
}
