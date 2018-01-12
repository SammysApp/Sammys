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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        UserAPIClient.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
