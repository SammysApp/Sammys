//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class ItemsViewController: UIViewController {
    let viewModel = ItemsViewModel()
    
    private let tableView = UITableView()
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case cell
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        configureTableView()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.cell.rawValue)
        tableView.edgesToSuperview()
    }
    
    private func configureViewModel() {
        viewModel.itemTableViewCellViewModelActions = [
            .configuration: itemTableViewCellConfigurationHandler
        ]
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - UITableViewCellViewModel Actions
    private func itemTableViewCellConfigurationHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ItemsViewModel.ItemTableViewCellViewModel,
            let cell = data.cell else { return }
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
}
