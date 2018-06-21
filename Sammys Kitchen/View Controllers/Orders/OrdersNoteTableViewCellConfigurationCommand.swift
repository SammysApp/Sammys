//
//  OrdersNoteTableViewCellConfigurationCommand.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrdersNoteTableViewCellConfigurationCommand: NoteTableViewCellConfigurationCommand {
    let note: String
    
    func perform(cell: NoteTableViewCell) {
        cell.textViewText = note
        cell.leftInset = OrdersConstants.cellLeftInset
        cell.isUserInteractionEnabled = false
    }
}
