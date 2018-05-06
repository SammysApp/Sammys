//
//  TextFieldTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    var textFieldTextDidChange: ((String?) -> Void)?
    
    @IBOutlet var textField: UITextField!
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        textFieldTextDidChange?(sender.text)
    }
}
