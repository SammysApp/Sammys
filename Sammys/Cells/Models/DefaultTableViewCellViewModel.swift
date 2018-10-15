//
//  DefaultTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct DefaultTableViewCellViewModel: TableViewCellViewModel {
    let identifier: String
    let height: CGFloat
    let isSelectable: Bool
    let isEditable: Bool
    let commands: [TableViewCommandActionKey : TableViewCellCommand]
    
    init(identifier: String, height: CGFloat, isSelectable: Bool = true, isEditable: Bool = true, commands: [TableViewCommandActionKey : TableViewCellCommand]) {
        self.identifier = identifier
        self.height = height
        self.isSelectable = isSelectable
        self.isEditable = isEditable
        self.commands = commands
    }
}
