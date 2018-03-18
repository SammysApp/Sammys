//
//  LoginPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A type representing the view controller and configurations to present.
enum LoginPageViewControllerKey: Int {
    /// LoginViewController
    case login
    /// SignUpViewController
    case name, email, password
    
    static var allValues = [login, name, email, password]
}

/// Presents the login option together with the sign up form if neccessary.
class LoginPageViewController: UIViewController, Storyboardable {
    typealias ViewController = LoginPageViewController
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private var currentPageIndex = 0 {
        didSet {
            // If the index has gone out of bounds, set to zero.
            if currentPageIndex == LoginPageViewControllerKey.allValues.count {
                currentPageIndex = 0
            }
        }
    }
    
    private var currentViewControllerKey: LoginPageViewControllerKey {
        return LoginPageViewControllerKey(rawValue: currentPageIndex)!
    }
    
    var signUpInfo = SignUpInfo() {
        didSet {
            updateNextButton()
        }
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var nextButton: UIButton!
    
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
    
    struct Constants {
        static let next = "Next"
        static let done = "Done"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewController(for: currentViewControllerKey, direction: .forward, animated: false)
        updateNextButton()
        
        // Set up page view controller.
        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)
        view.insertSubview(pageViewController.view, at: 0)
        
        NSLayoutConstraint.activate([
            pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func scrollToNextViewController() {
        currentPageIndex += 1
        // Scroll reverse if going to first view controller.
        setViewController(for: currentViewControllerKey, direction: (currentPageIndex == 0) ? .reverse : .forward, animated: true)
    }
    
    private func setViewController(for key: LoginPageViewControllerKey, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        let viewController: UIViewController
        if key == .login {
            let loginViewController = LoginViewController.storyboardInstance() as! LoginViewController
            loginViewController.didCancel = { self.dismiss(animated: true, completion: nil) }
            loginViewController.didSignUp = { self.scrollToNextViewController() }
            loginViewController.didCancel = {
                // FIXME: set didCancel in user vc
                self.dismiss(animated: true, completion: nil)
            }
            viewController = loginViewController
        } else {
            let signUpViewController = SignUpViewController.storyboardInstance() as! SignUpViewController
            signUpViewController.viewKey = key
            signUpViewController.didChangeInfo = { (key, text) in
                switch key {
                case .name: self.signUpInfo.name = text
                case .email: self.signUpInfo.email = text
                case .password: self.signUpInfo.password = text
                default: return
                }
            }
            viewController = signUpViewController
        }
        pageViewController.setViewControllers([viewController], direction: direction, animated: animated, completion: nil)
    }
    
    func updateNextButton() {
        nextButton.isHidden = true
        nextButton.setTitle(Constants.next, for: .normal)
        switch currentViewControllerKey {
        case .name:
            if signUpInfo.name != nil && signUpInfo.name != "" {
                nextButton.isHidden = false
            }
        case .email:
            if signUpInfo.email != nil && signUpInfo.email != "" {
                nextButton.isHidden = false
            }
        case .password:
            if signUpInfo.password != nil && signUpInfo.password != "" {
                nextButton.setTitle(Constants.done, for: .normal)
                nextButton.isHidden = false
            }
        default: break
        }
    }
    
    func createUser() {
        guard let name = signUpInfo.name,
            let email = signUpInfo.email,
            let password = signUpInfo.password else {
            return
        }
        // Create a Firebase user with the given information.
        UserAPIClient.createUser(with: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                // Create an empty customer for now and add to user.
                PayAPIClient.createNewCustomer(parameters: [PayAPIClient.Symbols.email: email]) { result in
                    switch result {
                    case .success(let customer):
                        UserAPIClient.set(customer.id, for: user)
                        self.dismiss(animated: true, completion: nil)
                    case .failure(_): break
                    }
                }
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
        if signUpInfo.allFieldsFilled {
            createUser()
        } else {
            scrollToNextViewController()
        }
    }
}
