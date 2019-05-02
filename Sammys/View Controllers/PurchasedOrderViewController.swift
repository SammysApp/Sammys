//
//  PurchasedOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/2/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasedOrderViewController: UIViewController {
    let viewModel = PurchasedOrderViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
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
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PurchasedOrderViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.progressTableViewCellViewModelActions = [
            .configuration: progressTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Cell Actions
    private func progressTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrderViewModel.ProgressTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
}
