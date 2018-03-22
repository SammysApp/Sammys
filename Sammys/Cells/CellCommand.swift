//
//  CellCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol CellCommand {
    func perform(parameters: [CommandParameterKey: Any]?)
}

enum CommandParameterKey {
    case cell
}

enum CommandActionKey {
    case configuration
    case selection
}
