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
		loginViewController.delegate = delegate
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
		setViewController(for: viewModel.currentPageIndex)
	}
	
	func setViewController(for pageIndex: LoginPageIndex, direction: UIPageViewControllerNavigationDirection = .forward, animated: Bool = false) {
		switch pageIndex {
		case .login: pageViewController.setViewControllers([loginViewController], direction: direction, animated: animated, completion: nil)
		case .name, .email, .password: break
		}
	}
    
    // MARK: IBActions
	@IBAction func didTapNext(_ sender: UIButton)   { viewModel.incrementOrLoopCurrentPageIndex(); setViewController(for: viewModel.currentPageIndex, animated: true) }
	
	@IBAction func didTapBack(_ sender: UIButton) { viewModel.decrementCurrentPageIndex(); setViewController(for: viewModel.currentPageIndex, direction: .reverse, animated: true) }
}

// MARK: - Storyboardable
extension LoginPageViewController: Storyboardable {}
