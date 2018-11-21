//
//  DefaultTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct DefaultTableViewCellViewModel: TableViewCellViewModel {
    let identifier: String
    let height: Double
    let isSelectable: Bool
    let isEditable: Bool
	let selectionHandler: (() -> Void)?
    let commands: [TableViewCommandActionKey : TableViewCellCommand]
    
    init(identifier: String, height: Double, isSelectable: Bool = true, isEditable: Bool = true, selectionHandler: (() -> Void)? = nil, commands: [TableViewCommandActionKey : TableViewCellCommand]) {
        self.identifier = identifier
        self.height = height
        self.isSelectable = isSelectable
        self.isEditable = isEditable
		self.selectionHandler = selectionHandler
        self.commands = commands
    }
}
