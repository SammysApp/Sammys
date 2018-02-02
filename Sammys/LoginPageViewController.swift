//
//  LoginPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

private enum ViewControllerKey: Int {
    case login, name, email, password
    
    static var allValues = [login, name, email, password]
}

class LoginPageViewController: UIViewController, Storyboardable {
    typealias ViewController = LoginPageViewController
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var currentIndex = 0 {
        didSet {
            if currentIndex == ViewControllerKey.allValues.count {
                currentIndex = 0
            }
        }
    }
    private var currentViewControllerKey: ViewControllerKey {
        return ViewControllerKey(rawValue: currentIndex)!
    }
    var signUpInfo = SignUpInfo() {
        didSet {
            updateNextButton()
        }
    }
    
    struct SignUpInfo {
        var name: String?
        var email: String?
        var password: String?
        
        var allFieldsFilled: Bool {
            return name != nil && email != nil && password != nil
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNextButton()
        scrollToViewController(for: currentViewControllerKey, direction: .forward, animated: false)
        
        addChildViewController(pageViewController)
        view.insertSubview(pageViewController.view, at: 0)
        pageViewController.didMove(toParentViewController: self)
        
        pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func scrollToNextViewController() {
        currentIndex += 1
        scrollToViewController(for: currentViewControllerKey, direction: (currentViewControllerKey == .login) ? .reverse : .forward, animated: true)
    }
    
    private func scrollToViewController(for key: ViewControllerKey, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        let viewController: UIViewController
        let signUpViewController = SignUpViewController.storyboardInstance() as! SignUpViewController
        switch key {
        case .login:
            viewController = LoginViewController.storyboardInstance()
        case .name:
            signUpViewController.viewKey = .name
            viewController = signUpViewController
        case .email:
            signUpViewController.viewKey = .email
            viewController = signUpViewController
        case .password:
            signUpViewController.viewKey = .password
            viewController = signUpViewController
        }
        updateNextButton()
        pageViewController.setViewControllers([viewController], direction: direction, animated: animated, completion: nil)
    }
    
    func updateNextButton() {
        nextButton.isHidden = true
        nextButton.setTitle("Next", for: .normal)
        switch currentViewControllerKey {
        case .login: break
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
                nextButton.isHidden = false
                nextButton.setTitle("Done", for: .normal)
            }
        }
    }
    
    func createUser() {
        guard let name = signUpInfo.name,
            let email = signUpInfo.email,
            let password = signUpInfo.password else {
            return
        }
        UserAPIClient.createUser(withName: name, email: email, password: password) { result in
            switch result {
            case .success:
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func next(_ sender: UIButton) {
        if signUpInfo.allFieldsFilled {
            createUser()
        } else {
            scrollToNextViewController()
        }
    }
}
