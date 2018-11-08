//
//  UserSettingsButtonTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum UserSettingsButtonCellIdentifier: String {
    case buttonCell
}

struct UserSettingsButtonTableViewCellViewModelFactory/*: TableViewCellViewModelFactory*/ {
    let height: CGFloat
    let didSelect: () -> Void
    
//    func create() -> TableViewCellViewModel {
//        let configurationCommand = UserSettingsButtonTableViewCellConfigurationCommand()
//        let selectionCommand = UserSettingsButtonTableViewCellSelectionCommand(didSelect: didSelect)
//		return DefaultTableViewCellViewModel(identifier: UserSettingsButtonCellIdentifier.buttonCell.rawValue, height: height, commands: [:])
//    }
}
