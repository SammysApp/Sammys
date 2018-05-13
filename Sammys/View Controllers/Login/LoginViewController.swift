//
//  LoginViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// The login page for a user to login 🔐.
class LoginViewController: UIViewController {
    let viewModel = LoginViewModel()
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.contextViewController = self
        viewModel.delegate = self
    }
    
    func updateUI() {
        signUpButton?.isHidden = viewModel.signUpIsHidden
    }
    
    // MARK: - IBActions
    @IBAction func didTapLogin(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        viewModel.loginWithEmail(email, password: password)
    }
    
    @IBAction func didTapFacebook(_ sender: UIButton) {
        viewModel.loginWithFacebook()
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        viewModel.didTapSignUp?()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        viewModel.didCancel?()
    }
}

extension LoginViewController: LoginViewModelDelegate {}

extension LoginViewController: Storyboardable {
    typealias ViewController = LoginViewController
}
