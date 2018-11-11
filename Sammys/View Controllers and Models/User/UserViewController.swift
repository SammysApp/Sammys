//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// The user's 👩🏻 information and settings.
class UserViewController: UIViewController, Storyboardable {
//    typealias ViewController = UserViewController
//
//    let viewModel = UserViewModel()
//
//    var shouldDismiss = false
//
//    // MARK: - IBOutlets & View Properties
//    @IBOutlet var tableView: UITableView!
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        viewModel.delegate = self
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        guard !shouldDismiss else { dismiss(animated: true, completion: nil); return }
//        // Prompt to login if needed.
//        if viewModel.needsUser {
//            presentLoginPageViewController()
//        }
//    }
//    // MARK: -
//
//    func presentLoginPageViewController() {
//        let loginPageViewController = LoginPageViewController.storyboardInstance() as! LoginPageViewController
//        loginPageViewController.delegate = self
//        present(loginPageViewController, animated: true, completion: nil)
//    }
//
//    // MARK: - IBActions
//    @IBAction func didTapSettings(_ sender: UIBarButtonItem) {
//        navigationController?.pushViewController(UserSettingsViewController.storyboardInstance(), animated: true)
//    }
//
//    @IBAction func didTapDone(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
}

// MARK: - TableViewDataSource & UITableViewDelegate
//extension UserViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return viewModel.numberOfSections
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.numberOfRows(in: section)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellViewModel = viewModel.cellViewModel(for: indexPath)
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError() }
//        cellViewModel.commands[.configuration]?.perform(cell: cell)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return viewModel.sectionTitle(for: section)
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        viewModel.cellViewModel(for: indexPath).commands[.selection]?.perform(cell: cell)
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return viewModel.cellViewModel(for: indexPath).height
//    }
//}
//
//// MARK: - UserViewModelDelegate
//extension UserViewController: UserViewModelDelegate {
//    var userDidChange: () -> Void {
//        return {
//            self.tableView.reloadData()
//            if self.viewModel.needsUser {
//                self.presentLoginPageViewController()
//            }
//        }
//    }
//
//    var didSelectOrders: () -> Void {
//        return { self.navigationController?.pushViewController(OrdersViewController.storyboardInstance(), animated: true) }
//    }
//
//    var didSelectLogOut: () -> Void {
//        return { try! UserAPIManager.signOut() }
//    }
//}
//
//extension UserViewController: LoginPageViewControllerDelegate {
//    func loginPageViewControllerDidCancel(_ loginPageViewController: LoginPageViewController) {
//        shouldDismiss = true
//    }
//
//    func loginPageViewControllerDidLogin(_ loginPageViewController: LoginPageViewController) {
//
//    }
//}
