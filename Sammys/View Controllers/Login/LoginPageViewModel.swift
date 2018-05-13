//
//  LoginPageViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type representing the view controller and configurations to present.
enum LoginPageViewControllerKey: Int {
    /// LoginViewController
    case login
    /// SignUpViewController
    case name, email, password
    
    static var allValues = [login, name, email, password]
}

/// A type representing the required sign up information.
struct SignUpInfo {
    /// The name of the user.
    var name: String?
    /// The user's email.
    var email: String?
    /// The user's password.
    var password: String?
    
    var allFieldsFilled: Bool {
        return name != nil && email != nil && password != nil
    }
}

class LoginPageViewModel {
    private struct Constants {
        static let next = "Next"
        static let done = "Done"
    }
    
    private var currentPageIndex = 0 {
        didSet {
            // If the index has gone out of bounds, set to zero.
            if currentPageIndex == LoginPageViewControllerKey.allValues.count {
                currentPageIndex = 0
            }
        }
    }
    
    var currentViewControllerKey: LoginPageViewControllerKey {
        return LoginPageViewControllerKey(rawValue: currentPageIndex)!
    }
    
    var signUpInfo = SignUpInfo()
    
    // MARK: - Next Button
    var nextButtonShouldHide: Bool {
        switch currentViewControllerKey {
        case .name:
            if signUpInfo.name != nil && signUpInfo.name != "" {
                return false
            }
        case .email:
            if signUpInfo.email != nil && signUpInfo.email != "" {
                return false
            }
        case .password:
            if signUpInfo.password != nil && signUpInfo.password != "" {
                return false
            }
        default: break
        }
        return true
    }
    
    var nextButtonTitle: String {
        if currentViewControllerKey == .password && signUpInfo.password != nil && signUpInfo.password != "" {
            return Constants.done
        }
        return Constants.next
    }
    
    func incrementViewControllerKey() {
        currentPageIndex += 1
    }
    
    func setSignUpInfo(for key: LoginPageViewControllerKey, withString string: String) {
        switch key {
        case .name: signUpInfo.name = string
        case .email: signUpInfo.email = string
        case .password: signUpInfo.password = string
        default: break
        }
    }
    
    func createUser(completed: @escaping (Bool) -> Void) {
        guard let name = signUpInfo.name,
            let email = signUpInfo.email,
            let password = signUpInfo.password else { return }
        // Create a Firebase user with the given information.
        UserAPIClient.createUser(with: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                // Create an empty customer for now and add to user.
                PayAPIClient.createNewCustomer(parameters: [PayAPIClient.Symbols.email: email]) { result in
                    switch result {
                    case .success(let customer):
                        UserAPIClient.set(customer.id, for: user)
                        completed(true)
                    case .failure(_): completed(false)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
