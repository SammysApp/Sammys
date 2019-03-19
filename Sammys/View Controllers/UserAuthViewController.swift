//
//  UserAuthViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class UserAuthViewController: UIViewController {
    let viewModel = UserAuthViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case textFieldTableViewCell
    }
    
    private struct Constants {
        static let textFieldTableViewCellTitleLabelWidth: CGFloat = 120
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureViewModel()
        configureTableView()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: CellIdentifier.textFieldTableViewCell.rawValue)
        tableView.edgesToSuperview()
        let sectionModels = viewModel.makeTableViewSectionModels()
        tableViewDataSource.sectionModels = sectionModels
        tableViewDelegate.sectionModels = sectionModels
        tableView.reloadData()
    }
    
    private func configureViewModel() {
        viewModel.textFieldTableViewCellViewModelActions = [
            .configuration: textFieldTableViewCellConfigurationAction
        ]
    }
    
    // MARK: - Cell Actions
    private func textFieldTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserAuthViewModel.TextFieldTableViewCellViewModel,
            let cell = data.cell as? TextFieldTableViewCell else { return }
        cell.titleLabelWidth = Constants.textFieldTableViewCellTitleLabelWidth
        cell.titleLabel.text = cellViewModel.configurationData.title
        cell.textFieldTextUpdateHandler = cellViewModel.configurationData.textFieldTextUpdateHandler
    }
}
