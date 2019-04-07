//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    let viewModel = UserViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var doneBarButtonItemTarget = Target(action: doneBarButtonItemAction)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
        configureNavigation()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
    }
    
    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: doneBarButtonItemTarget)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UserViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.userDetailTableViewCellViewModelActions = [
            .configuration: userDetailTableViewCellConfigrationAction
        ]
        
        viewModel.buttonTableViewCellViewModelActions = [
            .configuration: buttonTableViewCellConfigrationAction,
            .selection: buttonTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.errorHandler = { error in
            switch error {
            case UserAuthManagerError.noCurrentUser:
                self.present(UINavigationController(rootViewController: self.makeUserAuthPageViewController()), animated: true, completion: nil)
            default: print(error)
            }
        }
    }
    
    // MARK: - Factory Methods
    private func makeUserAuthPageViewController() -> UserAuthPageViewController {
        let userAuthPageViewController = UserAuthPageViewController()
        
        let userDidSignInHandler: (User.ID) -> Void = { id in
            self.viewModel.userID = id
            self.viewModel.beginDownloads()
            userAuthPageViewController.dismiss(animated: true, completion: nil)
        }
        
        userAuthPageViewController.existingUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        userAuthPageViewController.newUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        return userAuthPageViewController
    }
    
    // MARK: - Target Actions
    private func doneBarButtonItemAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func userDetailTableViewCellConfigrationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserViewModel.UserDetailTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.textAlignment = .natural
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
    
    private func buttonTableViewCellConfigrationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserViewModel.ButtonTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = cellViewModel.configurationData.title
    }
    
    private func buttonTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserViewModel.ButtonTableViewCellViewModel else { return }
        
        switch cellViewModel.selectionData.button {
        case .logOut:
            do {
                try viewModel.logOut()
                self.dismiss(animated: true, completion: nil)
            }
            // FIXME: Present error message.
            catch { print(error.localizedDescription) }
        }
    }
}
