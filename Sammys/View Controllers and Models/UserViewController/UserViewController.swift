//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol UserViewControllerDelegate: LoginViewControllerDelegate {}

class UserViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: UserViewModelParcel!
	private lazy var viewModel = UserViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	var delegate: UserViewControllerDelegate?
	
	var shouldShowLoginPageViewController = true
	lazy var loginPageViewController: LoginPageViewController = {
		let loginPageViewController = LoginPageViewController.storyboardInstance()
		loginPageViewController.delegate = self
		return loginPageViewController
	}()
	
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!

	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let cellHeight: Double = 60
	}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if shouldShowLoginPageViewController, case .noUser = viewModel.userState
		{ present(loginPageViewController, animated: true, completion: nil) }
	}
	
	func loadViews() {
		tableView.reloadData()
	}
	
	// MARK: - IBActions
	@IBAction func didTapDone(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func didTapSettings(_ sender: UIBarButtonItem) {}
}

// MARK: - Storyboardable
extension UserViewController: Storyboardable {}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(inSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier)
			else { fatalError("Can't dequeue reusable cell with identifier: \(cellViewModel.identifier)") }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(viewModel.cellViewModel(for: indexPath).height)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.cellViewModel(for: indexPath).selectionHandler?()
	}
}

// MARK: - UserViewModelViewDelegate
extension UserViewController: UserViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
	
	func userViewModel(_ viewModel: UserViewModel, didUpdate userState: UserState) {
		loadViews()
		if case .noUser = userState { dismiss(animated: true, completion: nil) }
	}
}

// MARK: - LoginPageViewControllerDelegate
extension UserViewController: LoginPageViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) {
		delegate?.loginViewController(loginViewController, didFinishLoggingIn: user)
		viewModel.userState = .currentUser(user)
		loadViews()
		loginViewController.dismiss(animated: true, completion: nil)
	}
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) {}
	
	func loginViewControllerDidCancel(_ loginViewController: LoginViewController) {
		shouldShowLoginPageViewController = false
		loginViewController.dismiss(animated: true) {
			self.dismiss(animated: true, completion: nil)
			self.shouldShowLoginPageViewController = true
		}
	}
}
