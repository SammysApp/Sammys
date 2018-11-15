//
//  LoginViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User)
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error)
}

class LoginViewController: UIViewController {
	var viewModelParcel = LoginViewModelParcel(method: .login) {
		didSet { viewModel = LoginViewModel(viewModelParcel) }
	}
    private lazy var viewModel = LoginViewModel(viewModelParcel)
	
	var delegate: LoginViewControllerDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
	
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
	@IBOutlet var facebookButton: UIButton!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	private struct Constants {
		static let facebookButtonCornerRadius: CGFloat = 20
		static let loginButtonCornerRadius: CGFloat = 20
	}
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupLoginButton()
		setupFacebookButton()
	}
	
	func setupLoginButton() {
		loginButton.layer.cornerRadius = Constants.loginButtonCornerRadius
	}
	
	func setupFacebookButton() {
		facebookButton.layer.cornerRadius = Constants.facebookButtonCornerRadius
	}
    
    // MARK: - IBActions
    @IBAction func didTapLogin(_ sender: UIButton) {
		guard let email = emailTextField.text, let password = passwordTextField.text
			else { return }
		viewModel.login(with: LoginDetails(email: email, password: password))
		.get { self.delegate?.loginViewController(self, didFinishLoggingIn: $0) }
		.catch { self.delegate?.loginViewController(self, couldNotLoginDueTo: $0) }
    }
	
	@IBAction func didTapSignUp(_ sender: UIButton) {}
    
    @IBAction func didTapFacebook(_ sender: UIButton) {}
    
    @IBAction func didTapCancel(_ sender: UIButton) {}
}

// MARK: - Storyboardable
extension LoginViewController: Storyboardable {}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true); return true
    }
}
