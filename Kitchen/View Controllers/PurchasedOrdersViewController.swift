//
//  PurchasedOrdersViewController.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/17/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasedOrdersViewController: UIViewController {
    let viewModel = PurchasedOrdersViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private struct Constants {
        static let title = "Today"
        
        static let navigationBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let tableViewSeparatorLeftInset = CGFloat(20)
        
        static let purchasedOrderTableViewCellPendingSideBarColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        static let purchasedOrderTableViewCellPreparingSideBarColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2196078431, alpha: 1)
        static let purchasedOrderTableViewCellCompletedSideBarColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        configureTableView()
        setUpView()
        configureNavigation()
        configureViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.beginDownloads()
        self.tableView.deselectSelectedRow(animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setUp() {
        self.title = Constants.title
    }
    
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
    }
    
    private func configureNavigation() {
        self.navigationController?.navigationBar.tintColor = Constants.navigationBarTintColor
    }
    
    private func configureTableView() {
        tableView.separatorInset = .left(Constants.tableViewSeparatorLeftInset)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: PurchasedOrdersViewModel.CellIdentifier.orderTableViewCell.rawValue)
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
            let cell = data.cell as? OrderTableViewCell else { return }
        
        cell.titleLabel.text = cellViewModel.configurationData.titleText
        cell.descriptionLabel.text = cellViewModel.configurationData.descriptionText
        cell.dateLabel.text = cellViewModel.configurationData.dateText
        
        if cellViewModel.configurationData.isPickupDateText {
            cell.setUpForPickupDate()
        } else { cell.setUpForDefaultDate() }
        
        switch cellViewModel.configurationData.progress {
        case .isPending: cell.sideBar.backgroundColor = Constants.purchasedOrderTableViewCellPendingSideBarColor
        case .isPreparing: cell.sideBar.backgroundColor = Constants.purchasedOrderTableViewCellPreparingSideBarColor
        case .isCompleted: cell.sideBar.backgroundColor = Constants.purchasedOrderTableViewCellCompletedSideBarColor
        }
    }
    
    private func purchasedOrderTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrdersViewModel.PurchasedOrderCellViewModel else { return }
        self.navigationController?.pushViewController(makePurchasedOrderViewController(purchasedOrderID: cellViewModel.selectionData.id, title: cellViewModel.selectionData.title), animated: true)
    }
}
