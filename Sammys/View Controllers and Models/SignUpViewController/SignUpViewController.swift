//
//  SignUpViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
    
    // MARK: - IBActions
    @IBAction func textFieldDidChangeEditing(_ sender: UITextField) {}
}

// MARK: - Storyboardable
extension SignUpViewController: Storyboardable {}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true); return true
    }
}
