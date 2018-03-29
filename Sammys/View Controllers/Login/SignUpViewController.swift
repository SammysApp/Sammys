//
//  SignUpViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

// The sign up page for a user 📝.
class SignUpViewController: UIViewController, Storyboardable {
    typealias ViewController = SignUpViewController
    
    var viewKey = LoginPageViewControllerKey.name {
        didSet {
            if isViewLoaded {
                updateUI(with: viewKey)
            }
        }
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    /// Called when text field for sign up info edited.
    var didChangeInfo: ((_ key: LoginPageViewControllerKey, _ text: String?) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI(with: viewKey)
    }
    
    func updateUI(with key: LoginPageViewControllerKey) {
        titleLabel.text = key.title
    }
    
    // MARK: - IBActions
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        didChangeInfo?(viewKey, textField.text)
    }
}

extension LoginPageViewControllerKey {
    var title: String? {
        switch self {
        case .name: return "Name"
        case .email: return "Email"
        case .password: return "Password"
        default: return nil
        }
    }
}
