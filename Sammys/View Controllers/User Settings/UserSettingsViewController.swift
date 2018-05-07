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
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        presentReauthenticateAlertController()
    }
    
    func presentReauthenticateAlertController(isAfterError: Bool = false) {
        let reauthenticateAlertController = UIAlertController(title: isAfterError ? "Oops! Try Again" : nil, message: "Please login again to edit your information.", preferredStyle: .alert)
        reauthenticateAlertController.addTextField { $0.placeholder = "Email" }
        reauthenticateAlertController.addTextField { $0.placeholder = "Password" }
        [UIAlertAction(title: "Login", style: .default) { action in
            guard let email = reauthenticateAlertController.textFields?[0].text,
                let password = reauthenticateAlertController.textFields?[1].text else { return }
            self.viewModel.reauthenticate(withEmail: email, password: password) {
                if $0 != nil { self.presentReauthenticateAlertController(isAfterError: true) }
                else { reauthenticateAlertController.dismiss(animated: true, completion: nil) }
            }
        },
        UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.navigationController?.popViewController(animated: true)
        }].forEach { reauthenticateAlertController.addAction($0) }
        present(reauthenticateAlertController, animated: true, completion: nil)
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
}

extension UserSettingsViewController: Storyboardable {
    typealias ViewController = UserSettingsViewController
}
