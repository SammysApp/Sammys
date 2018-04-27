//
//  LoginViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// The login page for a user to login 🔑.
class LoginViewController: UIViewController, Storyboardable {
    typealias ViewController = LoginViewController
    
    /// Called once finished logging in.
    var didLogin: (() -> Void)?
    
    /// Called if sign up tapped.
    var didTapSignUp: (() -> Void)?
    
    /// Called if cancel tapped.
    var didCancel: (() -> Void)?
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func didTapLogin(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        UserAPIClient.signIn(with: email, password: password) { result in
            self.didLogin?()
        }
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        didTapSignUp?()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        didCancel?()
    }
}
