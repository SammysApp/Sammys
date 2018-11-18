//
//  LoginPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol LoginPageViewControllerDelegate: LoginViewControllerDelegate {}

class LoginPageViewController: UIViewController {
    private let viewModel = LoginPageViewModel()
    
    var delegate: LoginPageViewControllerDelegate?
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	private lazy var loginViewController: LoginViewController = {
		let loginViewController = LoginViewController.storyboardInstance()
		loginViewController.delegate = self
		return loginViewController
	}()
    
    // MARK: - IBOutlets
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupChildPageViewController()
	}
	
	func setupChildPageViewController() {
		add(asChildViewController: pageViewController)
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.view.fullViewConstraints(equalTo: view).activateAll()
		view.sendSubview(toBack: pageViewController.view)
		setViewController(for: viewModel.currentPage)
	}
	
	func signUpViewController(for loginPage: LoginPage) -> SignUpViewController {
		let signupViewController = SignUpViewController.storyboardInstance()
		signupViewController.delegate = self
		signupViewController.titleText = loginPage.rawValue.uppercased()
		return signupViewController
	}
	
	func setViewController(for page: LoginPage, direction: UIPageViewControllerNavigationDirection = .forward, animated: Bool = false) {
		switch page {
		case .login: pageViewController.setViewControllers([loginViewController], direction: direction, animated: animated, completion: nil)
		case .name, .email, .password: pageViewController.setViewControllers([signUpViewController(for: page)], direction: direction, animated: animated, completion: nil)
		}
	}
    
    // MARK: IBActions
	@IBAction func didTapNext(_ sender: UIButton)   { viewModel.incrementOrLoopCurrentPage(); setViewController(for: viewModel.currentPage, animated: true) }
	
	@IBAction func didTapBack(_ sender: UIButton) { viewModel.decrementCurrentPage(); setViewController(for: viewModel.currentPage, direction: .reverse, animated: true) }
}

// MARK: - Storyboardable
extension LoginPageViewController: Storyboardable {}

extension LoginPageViewController: LoginViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) { delegate?.loginViewController(loginViewController, didFinishLoggingIn: user) }
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) { delegate?.loginViewController(loginViewController, couldNotLoginDueTo: error) }
	
	func loginViewControllerDidTapSignUp(_ loginViewController: LoginViewController) {
		viewModel.currentPage = .firstSignUpPage
		setViewController(for: viewModel.currentPage, animated: true)
		delegate?.loginViewControllerDidTapSignUp(loginViewController)
	}
	
	func loginViewControllerDidCancel(_ loginViewController: LoginViewController) { delegate?.loginViewControllerDidCancel(loginViewController) }
}

// MARK: - SignUpViewControllerDelegate
extension LoginPageViewController: SignUpViewControllerDelegate {
	func signUpViewController(_ signUpViewController: SignUpViewController, textFieldDidChangeEditing textField: UITextField) {
		
	}
}
