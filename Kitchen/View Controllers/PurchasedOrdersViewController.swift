//
//  PurchasedOrdersViewController.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/17/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class PurchasedOrdersViewController: UIViewController {
    let viewModel = PurchasedOrdersViewModel()
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PurchasedOrdersViewModel.CellIdentifier.orderTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.purchasedOrderCellViewModelActions = [
            .configuration: purchasedOrderTableViewCellConfigurationAction,
            .selection: purchasedOrderTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.errorHandler = { error in
            switch error {
            default: print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Factory Methods
    private func makePurchasedOrderViewController(purchasedOrderID: PurchasedOrder.ID, title: String? = nil) -> PurchasedOrderViewController {
        let purchasedOrderViewController = PurchasedOrderViewController()
        purchasedOrderViewController.title = title
        purchasedOrderViewController.viewModel.purchasedOrderID = purchasedOrderID
        return purchasedOrderViewController
    }
    
    // MARK: - Cell Actions
    private func purchasedOrderTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrdersViewModel.PurchasedOrderCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.text = cellViewModel.configurationData.titleText
    }
    
    private func purchasedOrderTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrdersViewModel.PurchasedOrderCellViewModel else { return }
        self.navigationController?.pushViewController(makePurchasedOrderViewController(purchasedOrderID: cellViewModel.selectionData.id, title: cellViewModel.selectionData.title), animated: true)
    }
}
