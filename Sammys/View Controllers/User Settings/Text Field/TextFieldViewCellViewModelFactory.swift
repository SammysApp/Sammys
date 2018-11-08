//
//  TextFieldViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum TextFieldCellIdetifier: String {
    case textFieldCell
}

struct TextFieldTableViewCellViewModelFactory/*: TableViewCellViewModelFactory*/ {
    let height: CGFloat
    let text: String
    let placeholder: String
    let textDidChange: ((String, TextFieldTableViewCell) -> Void)
    
//    func create() -> TableViewCellViewModel {
//        let configurationCommand = TextFieldTableViewCellConfigurationCommand(text: text, placeholder: placeholder, textDidChange: textDidChange)
//        return DefaultTableViewCellViewModel(identifier: TextFieldCellIdetifier.textFieldCell.rawValue, height: height, commands: [:])
//    }
}
