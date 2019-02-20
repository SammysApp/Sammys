//
//  BasicTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct BasicTableViewCellViewModel: TableViewCellViewModel {
    let identifier: String
    let height: Double
    let isSelectable: Bool
    let commands: [TableViewCellCommandAction: TableViewCellCommand]
    
    init(identifier: String,
         height: Double,
         isSelectable: Bool = true,
         commands: [TableViewCellCommandAction: TableViewCellCommand]) {
        self.identifier = identifier
        self.height = height
        self.isSelectable = isSelectable
        self.commands = commands
    }
}
