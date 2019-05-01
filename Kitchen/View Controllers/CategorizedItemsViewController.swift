//
//  CategorizedItemsViewController.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CategorizedItemsViewController: UIViewController {
    let viewModel = CategorizedItemsViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private struct Constants {
        static let itemTableViewCellTextLabelFontSize = CGFloat(18)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CategorizedItemsViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.itemTableViewCellViewModelActions = [
            .configuration: itemTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Cell Actions
    private func itemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategorizedItemsViewModel.ItemTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.font = .systemFont(ofSize: Constants.itemTableViewCellTextLabelFontSize)
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
}
