//
//  LoginViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import FBSDKLoginKit

enum LoginMethod {
    case login, reauthenticate
}

protocol LoginViewModelDelegate {
    func updateUI()
}

class LoginViewModel {
    var contextViewController: UIViewController?
    
    var delegate: LoginViewModelDelegate?
    
    var loginMethod = LoginMethod.login
    
    var signUpIsHidden = false {
        didSet {
            delegate?.updateUI()
        }
    }
    
    /// Called once finished logging in.
    var didLogin: (() -> Void)?
    
    /// Called if sign up tapped.
    var didTapSignUp: (() -> Void)?
    
    /// Called if cancel tapped.
    var didCancel: (() -> Void)?
    
    private struct Constants {
        static let facebookLoginReadPermissions = ["email", "public_profile"]
    }
    
    func loginWithEmail(_ email: String, password: String) {
        switch loginMethod {
        case .login:
            UserAPIClient.signIn(withEmail: email, password: password) { result in
                // FIXME: Handle bad password or something
                self.didLogin?()
            }
        case .reauthenticate:
            UserAPIClient.reauthenticate(withEmail: email, password: password) { result in
                self.didLogin?()
            }
        }
    }
    
    func loginWithFacebook() {
        guard let viewController = contextViewController else { return }
        FBSDKLoginManager().logIn(withReadPermissions: Constants.facebookLoginReadPermissions, from: viewController) { result, error in
            if error == nil {
                guard let accessTokenString = FBSDKAccessToken.current()?.tokenString else { return }
                switch self.loginMethod {
                case .login:
                    UserAPIClient.signIn(withFacebookAccessToken: accessTokenString) { result in
                        self.didLogin?()
                        switch result {
                        case .success(let user): UserAPIClient.set(.facebook, for: user)
                        case .failure(let error): print(error)
                        }
                    }
                case .reauthenticate:
                    UserAPIClient.reauthenticate(withFacebookAccessToken: accessTokenString) { result in
                        self.didLogin?()
                    }
                }
            }
        }
    }
}
