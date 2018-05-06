//
//  TextFieldTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct TextFieldTableViewCellConfigurationCommand: TableViewCellCommand {
    let text: String
    let placeholder: String
    let textDidChange: ((String) -> Void)
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? TextFieldTableViewCell else { return }
        cell.textField.text = text
        cell.textField.placeholder = placeholder
        cell.textFieldTextDidChange = { text in
            cell.textField.text = text
            self.textDidChange(text ?? "")
        }
    }
}
