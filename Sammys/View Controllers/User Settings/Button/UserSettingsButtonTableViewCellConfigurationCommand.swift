//
//  UserSettingsButtonTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct UserSettingsButtonTableViewCellConfigurationCommand: TableViewCellCommand {
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? UserSettingsButtonTableViewCell,
            let user = UserDataStore.shared.user else { return }
        
        cell.activityIndicatorView.startAnimating()
        UserAPIClient.userHasEmailAuthenticationProvider(user) {
            cell.activityIndicatorView.stopAnimating()
            if $0 { cell.titleLabel.text = "Update Password" }
            else { cell.titleLabel.text = "Add Password" }
        }
    }
}
