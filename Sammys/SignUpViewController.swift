//
//  SignUpViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum SignUpViewKey: String {
    case name = "Name", email = "Email", password = "Password"
}

class SignUpViewController: UIViewController, Storyboardable {
    typealias ViewController = SignUpViewController
    
    var viewKey = SignUpViewKey.name {
        didSet {
            if isViewLoaded {
                updateUI(with: viewKey)
            }
        }
    }
    var loginPageViewController: LoginPageViewController? {
        return parent?.parent as? LoginPageViewController
    }
    
    // MARK: IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI(with: viewKey)
    }
    
    func updateUI(with key: SignUpViewKey) {
        titleLabel.text = key.rawValue
    }
    
    // MARK: IBActions
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        switch viewKey {
        case .name:
            loginPageViewController?.signUpInfo.name = textField.text
        case .email:
            loginPageViewController?.signUpInfo.email = textField.text
        case .password:
            loginPageViewController?.signUpInfo.password = textField.text
        }
        
    }
}
