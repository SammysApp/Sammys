//
//  LoginViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, Storyboardable {
    typealias ViewController = LoginViewController
    
    var loginPageViewController: LoginPageViewController? {
        return parent?.parent as? LoginPageViewController
    }
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        UserAPIClient.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            self.loginPageViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        loginPageViewController?.scrollToNextViewController()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        if let userViewController = (loginPageViewController?.presentingViewController as? UINavigationController)?.topViewController as? UserViewController {
            userViewController.didCancelLogin = true
        }
        loginPageViewController?.dismiss(animated: true, completion: nil)
    }
}
