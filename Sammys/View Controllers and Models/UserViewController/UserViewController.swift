//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
	private lazy var viewModel = UserViewModel(self)
	
	let loginPageViewController: LoginPageViewController = { LoginPageViewController.storyboardInstance() }()
	var shouldPresentLoginIfNoUser = true
	
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
		
		viewModel.userState.bindAndRun(didChangeUserState)
		
		loginPageViewController.delegate = self
    }
	
	func loadViews() {
		tableView.reloadData()
	}
	
	func didChangeUserState(_ userState: UserState) {
		switch userState {
		case .noUser: if shouldPresentLoginIfNoUser
		{ present(loginPageViewController, animated: true, completion: nil) }
		shouldPresentLoginIfNoUser = false
		case .currentUser: loadViews()
		}
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
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier)
			else { fatalError("Can't dequeue reusable cell with identifier: \(cellViewModel.identifier)") }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}

// MARK: - UserViewModelViewDelegate
extension UserViewController: UserViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
}

// MARK: - LoginPageViewControllerDelegate
extension UserViewController: LoginPageViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) {
		loginViewController.dismiss(animated: true, completion: nil)
	}
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) {
		print(error)
	}
}
