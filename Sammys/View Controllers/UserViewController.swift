//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class UserViewController: UIViewController, Storyboardable {
    typealias ViewController = UserViewController
    
    let viewModel = UserViewModel()
    var didCancelLogin = false
    
    lazy var userDidChange: () -> Void = {
        self.tableView.reloadData()
        if self.viewModel.needsUser {
            self.presentLoginPageViewController()
        }
    }
    
    // MARK: IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.needsUser && !didCancelLogin {
            presentLoginPageViewController()
        }
        if didCancelLogin {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func presentLoginPageViewController() {
        let loginPageViewController = LoginPageViewController.storyboardInstance()
        present(loginPageViewController, animated: true, completion: nil)
    }

    // MARK: IBActions
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(for: indexPath)!
        func cell(for item: UserItem) -> UITableViewCell? {
            let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)
            cell?.textLabel?.text = item.title
            return cell
        }
        
        switch item.key {
        case .name:
            let nameItem = item as! NameUserItem
            let nameCell = cell(for: nameItem)!
            nameCell.detailTextLabel?.text = nameItem.name
            return nameCell
        case .email:
            let emailItem = item as! EmailUserItem
            let emailCell = cell(for: emailItem)!
            emailCell.detailTextLabel?.text = emailItem.email
            return emailCell
        case .creditCard, .logOut:
            return cell(for: item)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .logOut:
            let logOutItem = item as! LogOutUserItem
            logOutItem.didSelect()
        case .creditCard:
            let theme = STPTheme()
            theme.accentColor = UIColor(named: "Mocha")
            let addCardViewController = STPAddCardViewController()
            addCardViewController.delegate = self
            navigationController?.pushViewController(addCardViewController, animated: true)
        default: break
        }
    }
}

extension UserViewController: UserViewModelDelegate {}

extension UserViewController: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        PayAPIClient.createNewCustomer(with: token.tokenId)
        navigationController?.popViewController(animated: true)
    }
}
