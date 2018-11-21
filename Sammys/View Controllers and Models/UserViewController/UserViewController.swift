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
	/// Must be set for use of the view model.
	var viewModelParcel: UserViewModelParcel!
	{ didSet { viewModel = UserViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: UserViewModel!
	
	var delegate: UserViewControllerDelegate?
	
	var shouldShowLoginPageViewController = true
	
	// MARK: - View Controllers
	lazy var loginPageViewController: LoginPageViewController = {
		let loginPageViewController = LoginPageViewController.storyboardInstance()
		loginPageViewController.delegate = self
		return loginPageViewController
	}()
	
	lazy var ordersViewController: OrdersViewController = {
		let ordersViewController = OrdersViewController.storyboardInstance()
		return ordersViewController
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
		
		if case .noUser = viewModel.userState {
			viewModel.setupUserState()
				.get { self.handleUpdatedUserState($0, shouldShowLoginIfNoUser: self.shouldShowLoginPageViewController) }
				.catch { print($0) }
		}
	}
	
	// MARK: - Setup
	func loadViews() {
		tableView.reloadData()
	}
	
	// MARK: - Methods
	func handleUpdatedUserState(_ userState: UserState,
								shouldShowLoginIfNoUser: Bool = false) {
		loadViews()
		switch userState {
		case .currentUser: break
		case .noUser:
			if shouldShowLoginIfNoUser
			{ present(self.loginPageViewController, animated: true, completion: nil) }
		}
	}
	
	func logOut() {
		do {
			try viewModel.logOut()
			handleUpdatedUserState(.noUser)
			dismiss(animated: true, completion: nil)
		} catch { print(error) }
	}
	
	// MARK: - IBActions
	@IBAction func didTapDone(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func didTapSettings(_ sender: UIBarButtonItem) {}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)"
	}
	
	func cantDequeueCellMessage(forIdentifier identifier: String) -> String {
		return "Can't dequeue reusable cell with identifier: \(identifier)"
	}
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
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError(noCellViewModelMessage(for: indexPath)) }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier)
			else { fatalError(cantDequeueCellMessage(forIdentifier: cellViewModel.identifier)) }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError(noCellViewModelMessage(for: indexPath)) }
		return CGFloat(cellViewModel.height)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.cellViewModel(for: indexPath)?.commands[.selection]?.perform(parameters: TableViewCellCommandParameters(cell: tableView.cellForRow(at: indexPath), viewController: self))
	}
}

// MARK: - UserViewModelViewDelegate
extension UserViewController: UserViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
}

// MARK: - LoginPageViewControllerDelegate
extension UserViewController: LoginPageViewControllerDelegate {
	func loginPageViewController(_ loginPageViewController: LoginPageViewController, didSignUp user: User) {
		viewModel.userState = .currentUser(user)
		handleUpdatedUserState(viewModel.userState)
		loginPageViewController.dismiss(animated: true, completion: nil)
	}
	
	func loginPageViewController(_ loginPageViewController: LoginPageViewController, couldNotSignUpDueTo error: Error) { print(error) }
}

// MARK: - LoginViewControllerDelegate
extension UserViewController: LoginViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) {
		delegate?.loginViewController(loginViewController, didFinishLoggingIn: user)
		viewModel.userState = .currentUser(user)
		handleUpdatedUserState(viewModel.userState)
		loginViewController.dismiss(animated: true, completion: nil)
	}
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) { print(error) }
	
	func loginViewControllerDidTapSignUp(_ loginViewController: LoginViewController) {}
	
	func loginViewControllerDidCancel(_ loginViewController: LoginViewController) {
		shouldShowLoginPageViewController = false
		loginViewController.dismiss(animated: true) {
			self.dismiss(animated: true, completion: nil)
			self.shouldShowLoginPageViewController = true
		}
	}
}
