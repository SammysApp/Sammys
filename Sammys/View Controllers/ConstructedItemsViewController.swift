//
//  ConstructedItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/8/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ConstructedItemsViewController: UIViewController {
    let viewModel = ConstructedItemsViewModel()
    
    let tableView = UITableView()
    
    // MARK: - Lifecycle Methods
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private struct Constants {
        static let itemTableViewCellTitleLabelFontWeight = UIFont.Weight.medium
        static let itemTableViewCellDescriptionLabelTextColor = UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
        configureViewModel()
        
        beginDownloads()
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
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ConstructedItemsViewModel.CellIdentifier.itemTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.constructedItemCellViewModelActions = [
            .configuration: constructedItemTableViewCellConfigurationAction,
            .selection: constructedItemTableViewCellSelectionAction
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
    
    // MARK: - Methods
    func beginDownloads() {
        if viewModel.userID == nil {
            viewModel.beginUserIDDownload() {
                self.viewModel.beginDownloads()
            }
        } else { viewModel.beginDownloads() }
    }
    
    // MARK: - Cell Actions
    private func constructedItemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ConstructedItemsViewModel.ConstructedItemTableViewCellViewModel,
            let cell = data.cell as? ItemTableViewCell else { return }
        
        cell.titleLabel.font = .systemFont(ofSize: cell.titleLabel.font.pointSize, weight: Constants.itemTableViewCellTitleLabelFontWeight)
        cell.titleLabel.text = cellViewModel.configurationData.titleText
        
        cell.descriptionLabel.textColor = Constants.itemTableViewCellDescriptionLabelTextColor
        cell.descriptionLabel.text = cellViewModel.configurationData.descriptionText
        
        cell.priceLabel.text = cellViewModel.configurationData.priceText
        
        cell.quantityView.isHidden = true
    }
    
    private func constructedItemTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {}
}
