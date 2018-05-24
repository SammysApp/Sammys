//
//  LoginPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol LoginPageViewControllerDelegate {
    func loginPageViewControllerDidCancel(_ loginPageViewController: LoginPageViewController)
    func loginPageViewControllerDidLogin(_ loginPageViewController: LoginPageViewController)
}

/// Presents the login option together with the sign up form if neccessary.
class LoginPageViewController: UIViewController {
    private let viewModel = LoginPageViewModel()
    
    var delegate: LoginPageViewControllerDelegate?
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var loginViewController: LoginViewController {
        let loginViewController = LoginViewController.storyboardInstance() as! LoginViewController
        loginViewController.viewModel.didCancel = {
            self.delegate?.loginPageViewControllerDidCancel(self)
            self.dismiss(animated: true, completion: nil)
        }
        loginViewController.viewModel.didLogin = {
            self.delegate?.loginPageViewControllerDidLogin(self)
            self.dismiss(animated: true, completion: nil)
        }
        loginViewController.viewModel.didTapSignUp = { self.goToNextViewController() }
        return loginViewController
    }
    
    var signUpViewController: SignUpViewController {
        return SignUpViewController.storyboardInstance() as! SignUpViewController
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewController(for: viewModel.currentViewControllerKey, direction: .forward, animated: false)
        updateNextButton()
        updateBackButton()
        
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
    
    func goToNextViewController() {
        viewModel.incrementViewControllerKey()
        setViewController(for: viewModel.currentViewControllerKey, direction: .forward, animated: true)
        updateBackButton()
    }
    
    func goToPreviousViewController() {
        viewModel.decrementViewControllerKey()
        setViewController(for: viewModel.currentViewControllerKey, direction: .reverse, animated: true)
        updateNextButton()
        updateBackButton()
        viewModel.updateSignUpInfo()
    }
    
    private func setViewController(for key: LoginPageViewControllerKey, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        let viewController = key == .login ? loginViewController : signUpViewController(for: key)
        pageViewController.setViewControllers([viewController], direction: direction, animated: animated, completion: nil)
    }
    
    func updateNextButton() {
        nextButton.isHidden = viewModel.nextButtonShouldHide
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    }
    
    func updateBackButton() {
        backButton.isHidden = viewModel.backButtonShouldHide
    }
    
    func signUpViewController(for key: LoginPageViewControllerKey) -> SignUpViewController {
        let signUpViewController = self.signUpViewController
        signUpViewController.titleText = key.title
        signUpViewController.prefilledText = viewModel.signUpInfoText(for: key)
        signUpViewController.didUpdateText = { text in
            guard let text = text else { return }
            self.viewModel.setSignUpInfo(for: key, withString: text)
            self.updateNextButton()
        }
        return signUpViewController
    }
    
    // MARK: IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
        if viewModel.allFieldsFilled {
            viewModel.createUser { didSucceed in
                if didSucceed {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            goToNextViewController()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        goToPreviousViewController()
    }
}

extension LoginPageViewController: Storyboardable {
    typealias ViewController = LoginPageViewController
}
