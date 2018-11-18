//
//  SignUpViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol SignUpViewControllerDelegate {
	func signUpViewController(_ signUpViewController: SignUpViewController, textFieldDidChangeEditing textField: UITextField)
}

class SignUpViewController: UIViewController {
	var titleText: String? { didSet { titleLabel?.text = titleText } }
	
	var delegate: SignUpViewControllerDelegate?
	
    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel! { didSet { titleLabel.text = titleText } }
    @IBOutlet var textField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
    
    // MARK: - IBActions
    @IBAction func textFieldDidChangeEditing(_ sender: UITextField) { delegate?.signUpViewController(self, textFieldDidChangeEditing: sender) }
}

// MARK: - Storyboardable
extension SignUpViewController: Storyboardable {}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true); return true
    }
}
