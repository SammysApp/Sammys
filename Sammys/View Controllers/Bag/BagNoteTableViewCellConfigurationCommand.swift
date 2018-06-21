//
//  BagNoteTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct BagNoteTableViewCellConfigurationCommand: NoteTableViewCellConfigurationCommand {
    let parameters: NoteConfigurationParameters
    
    func perform(cell: NoteTableViewCell) {
        cell.leftInset = UITableView.standardLeftInset
        cell.placeholderText = "Any special requests? Type them here..."
        cell.tintColor = #colorLiteral(red: 0.3330000043, green: 0.3019999862, blue: 0.275000006, alpha: 1)
        cell.textViewDidChange = parameters.textViewDidChange
    }
}
