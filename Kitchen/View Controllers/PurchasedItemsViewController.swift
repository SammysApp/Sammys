//
//  PurchasedItemsViewController.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/18/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasedItemsViewController: UIViewController {
    let viewModel = PurchasedItemsViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    var categorizedItemsViewController: CategorizedItemsViewController? {
        return (self.splitViewController?.viewControllers[safe: 1] as? UINavigationController)?.viewControllers.first as? CategorizedItemsViewController
    }
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PurchasedItemsViewModel.CellIdentifier.itemTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.purchasedConstructedItemTableViewCellViewModelActions = [
            .configuration: purchasedConstructedItemTableViewCellConfigurationAction,
            .selection: purchasedConstructedItemTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.purchasedConstructedItemItems.bind { self.categorizedItemsViewController?.viewModel.categorizedItems = $0 }
        
        viewModel.errorHandler = { error in
            switch error {
            default: print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Cell Actions
    private func purchasedConstructedItemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedItemsViewModel.PurchasedConstructedItemTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.text = cellViewModel.configurationData.titleText
    }
    
    private func purchasedConstructedItemTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedItemsViewModel.PurchasedConstructedItemTableViewCellViewModel
            else { return }
        
        viewModel.beginPurchasedConstructedItemItemsDownload(id: cellViewModel.selectionData.id)
    }
}
