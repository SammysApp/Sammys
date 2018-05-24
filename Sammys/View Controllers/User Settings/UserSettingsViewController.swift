//
//  UserSettingsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {
    let viewModel = UserSettingsViewModel()
    var needsReauthentication = true
    var shouldPop = false
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard !shouldPop else { navigationController?.popViewController(animated: true); return }
        if needsReauthentication {
            presentLoginViewController()
        }
    }
    
    func presentLoginViewController() {
        let loginViewController = LoginViewController.storyboardInstance() as! LoginViewController
        loginViewController.viewModel.signUpIsHidden = true
        loginViewController.viewModel.loginMethod = .reauthenticate
        loginViewController.viewModel.didLogin = {
            loginViewController.dismiss(animated: true, completion: nil)
            self.needsReauthentication = false
        }
        loginViewController.viewModel.didCancel = {
            loginViewController.dismiss(animated: true, completion: nil)
            self.shouldPop = true
        }
        present(loginViewController, animated: true, completion: nil)
    }
    
    func presentPasswordAlert() {
        let alertController = UIAlertController(
            title: viewModel.userHasEmailAuthenticationProvider ? "Update Password" : "Add Password",
            message: nil,
            preferredStyle: .alert)
        alertController.addTextField { $0.placeholder = self.viewModel.userHasEmailAuthenticationProvider ? "New Password" : "Password" }
        [UIAlertAction(title: "Done", style: .default) { action in
            guard let password = alertController.textFields?[0].text else { return }
            if self.viewModel.userHasEmailAuthenticationProvider {
                self.viewModel.updatePassword(password) { completedSuccessfully in
                    self.tableView.deselectSelectedRow()
                    self.tableView.reloadData()
                }
            } else {
                self.viewModel.linkPassword(password) { completedSuccessfully in
                    self.tableView.deselectSelectedRow()
                    self.tableView.reloadData()
                }
            }
        },
         UIAlertAction(title: "Cancel", style: .cancel, handler: { action in alertController.dismiss(animated: true, completion: nil)})
        ].forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }
}

extension UserSettingsViewController: UserSettingsViewModelDelegate {
    func didStartUpdatingName(in cell: TextFieldTableViewCell) {
        cell.activityIndicatorView.startAnimating()
    }
    
    func didStartUpdatingEmail(in cell: TextFieldTableViewCell) {
        cell.activityIndicatorView.startAnimating()
    }
    
    func didFinishUpdatingName(in cell: TextFieldTableViewCell) {
        cell.activityIndicatorView.stopAnimating()
    }
    
    func didFinishUpdatingEmail(in cell: TextFieldTableViewCell) {
        cell.activityIndicatorView.stopAnimating()
    }
    
    func didTapPassword() {
        presentPasswordAlert()
    }
}

extension UserSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError() }
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellViewModel(for: indexPath).height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        viewModel.cellViewModel(for: indexPath).commands[.selection]?.perform(cell: cell)
    }
}

extension UserSettingsViewController: Storyboardable {
    typealias ViewController = UserSettingsViewController
}
