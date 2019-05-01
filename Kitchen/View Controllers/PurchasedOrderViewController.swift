//
//  PurchasedOrderViewController.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/18/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasedOrderViewController: UIViewController {
    let viewModel = PurchasedOrderViewModel()
    
    let tableView = UITableView()
    let completeButton = RoundedButton()
    
    var categorizedItemsViewController: CategorizedItemsViewController? {
        return (self.splitViewController?.viewControllers[safe: 1] as? UINavigationController)?.viewControllers.first as? CategorizedItemsViewController
    }
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    private struct Constants {
        static let purchasedConstructedItemTableViewCellTextLabelFontSize = CGFloat(18)
        static let purchasedConstructedItemTableViewCellTextLabelFontWeight = UIFont.Weight.medium
        
        static let completeButtonBackgroundColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        static let completeButtonTitleLabelTextColor = UIColor.white
        static let completeButtonTitleLabelTextFontSize = CGFloat(28)
        static let completeButtonTitleLabelFontWeight = UIFont.Weight.bold
        static let completeButtonTitleLabelText = "DONE"
        static let completeButtonHeight = CGFloat(80)
        static let completeButtonInset = CGFloat(10)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureCompleteButton()
        configureCategorizedItemsViewController()
        setUpView()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.categorizedItemsViewController?.title = nil
            self.viewModel.purchasedConstructedItemItems.value = []
        }
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView, completeButton]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        
        completeButton.edgesToSuperview(excluding: .top, insets: .uniform(Constants.completeButtonInset))
        completeButton.height(Constants.completeButtonHeight)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PurchasedOrderViewModel.CellIdentifier.itemTableViewCell.rawValue)
    }
    
    private func configureCompleteButton() {
        completeButton.backgroundColor = Constants.completeButtonBackgroundColor
        completeButton.titleLabel.textColor = Constants.completeButtonTitleLabelTextColor
        completeButton.titleLabel.font = .systemFont(ofSize: Constants.completeButtonTitleLabelTextFontSize, weight: Constants.completeButtonTitleLabelFontWeight)
        completeButton.titleLabel.text = Constants.completeButtonTitleLabelText
        
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureCategorizedItemsViewController() {
        categorizedItemsViewController?.tableView.allowsSelection = false
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
        
        viewModel.purchasedOrderIsCompleted.bindAndRun { self.completeButton.isHidden = $0 }
        
        viewModel.purchasedConstructedItemItems.bind { self.categorizedItemsViewController?.viewModel.categorizedItems = $0 }
        
        viewModel.errorHandler = { error in
            switch error {
            default: print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Target Actions
    private func completeButtonTouchUpInsideAction() {
        viewModel.beginUpdatePurchasedOrderProgressIsCompleted() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Cell Actions
    private func purchasedConstructedItemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrderViewModel.PurchasedConstructedItemTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.font = .systemFont(ofSize: Constants.purchasedConstructedItemTableViewCellTextLabelFontSize, weight: Constants.purchasedConstructedItemTableViewCellTextLabelFontWeight)
        cell.textLabel?.text = cellViewModel.configurationData.titleText
    }
    
    private func purchasedConstructedItemTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrderViewModel.PurchasedConstructedItemTableViewCellViewModel
            else { return }
        
        categorizedItemsViewController?.title = cellViewModel.selectionData.title
        viewModel.beginPurchasedConstructedItemItemsDownload(id: cellViewModel.selectionData.id)
    }
}
