//
//  PaymentMethodsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/14/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PaymentMethodsViewController: UIViewController {
    let viewModel = PaymentMethodsViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PaymentMethodsViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.paymentMethodTableViewCellViewModelActions = [
            .configuration: paymentMethodTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.errorHandler = { value in
            switch value {
            default: print(value.localizedDescription)
            }
        }
    }
    
    // MARK: - Cell Actions
    private func paymentMethodTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PaymentMethodsViewModel.PaymentMethodTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
}
