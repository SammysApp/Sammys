//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: UserViewModelParcel! {
		didSet { viewModel = UserViewModel(parcel: viewModelParcel, viewDelegate: self) }
	}
	private var viewModel: UserViewModel! { didSet { loadViews() } }
	
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
		
		if case .noUser = viewModel.userState
		{ present(loginPageViewController, animated: true, completion: nil) }
    }
	
	func loadViews() {
		tableView?.reloadData()
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

extension UserViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(viewModel.cellViewModel(for: indexPath).height)
	}
}

// MARK: - UserViewModelViewDelegate
extension UserViewController: UserViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
}

// MARK: - LoginPageViewControllerDelegate
extension UserViewController: LoginPageViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) {
		viewModelParcel.userState = .currentUser(user)
		loginViewController.dismiss(animated: true, completion: nil)
	}
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) {
		print(error)
	}
}
