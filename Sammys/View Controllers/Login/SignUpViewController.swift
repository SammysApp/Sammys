//
//  SignUpViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// The sign up page for a user 📝.
class SignUpViewController: UIViewController {
    var titleText: String?
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    /// Called when text field for sign up info edited.
    var didUpdateText: ((String?) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleText
    }
    
    // MARK: - IBActions
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        didUpdateText?(textField.text)
    }
}

extension SignUpViewController: Storyboardable {
    typealias ViewController = SignUpViewController
}
