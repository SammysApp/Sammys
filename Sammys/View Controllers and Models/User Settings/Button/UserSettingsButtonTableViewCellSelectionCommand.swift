//
//  UserSettingsButtonTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct UserSettingsButtonTableViewCellSelectionCommand/*: TableViewCellCommand*/ {
    let didSelect: () -> Void
    
    func perform(cell: UITableViewCell?) {
        didSelect()
    }
}
