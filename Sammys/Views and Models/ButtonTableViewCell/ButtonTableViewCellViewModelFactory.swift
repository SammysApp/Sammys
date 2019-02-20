//
//  ButtonTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ButtonTableViewCellViewModelFactory: TableViewCellViewModelFactory {
	let identifier: String
    let height: Double
    
    let text: String
    
    func create() -> BasicTableViewCellViewModel {
        let configuration = ButtonTableViewCellConfigurationCommand(text: text)
        return BasicTableViewCellViewModel(
            identifier: identifier,
            height: height,
            commands: [.configuration: configuration]
        )
    }
}
