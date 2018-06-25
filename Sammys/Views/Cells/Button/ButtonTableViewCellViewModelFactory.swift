//
//  ButtonTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum ButtonCellIdentifier: String {
    case buttonCell
}

struct ButtonTableViewCellViewModelFactory: TableViewCellViewModelFactory {
    let height: CGFloat
    let buttonText: String
    let selectionCommand: TableViewCellCommand?
    
    func create() -> TableViewCellViewModel {
        let configurationCommand = ButtonTableViewCellConfigurationCommand(buttonText: buttonText)
        var commands: [TableViewCommandActionKey : TableViewCellCommand] = [.configuration: configurationCommand]
        if let selectionCommand = selectionCommand {
            commands[.selection] = selectionCommand
        }
        return DefaultTableViewCellViewModel(identifier: ButtonCellIdentifier.buttonCell.rawValue, height: height, commands: commands)
    }
}
