//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    let viewModel = ItemsViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    var addItemHandler: ((ItemData) -> Void)?
    var removeItemHandler: ((ItemData) -> Void)?
    
    struct ItemData {
        let categoryItemID: UUID
    }
    
    private struct Constants {
        static let itemTableViewCellTextLabelFontSize: CGFloat = 18
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
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: ItemsViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.itemTableViewCellViewModelActions = [
            .configuration: itemTableViewCellConfigurationAction,
            .selection: itemTableViewCellSelectionAction
        ]
        viewModel.tableViewSectionModels.bind { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Cell Actions
    private func itemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ItemsViewModel.ItemTableViewCellViewModel,
            let cell = data.cell as? SubtitleTableViewCell else { return }
        cell.tintColor = #colorLiteral(red: 0.2509803922, green: 0.2, blue: 0.1529411765, alpha: 1)
        cell.textLabel?.font = .systemFont(ofSize: Constants.itemTableViewCellTextLabelFontSize)
        cell.textLabel?.text = cellViewModel.configurationData.text
        cell.detailTextLabel?.text = cellViewModel.configurationData.detailText
        if let id = cellViewModel.configurationData.categoryItemID, viewModel.selectedCategoryItemIDs.contains(id) {
            cell.accessoryType = .checkmark
        } else { cell.accessoryType = .none }
    }
    
    private func itemTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ItemsViewModel.ItemTableViewCellViewModel,
            let indexPath = data.indexPath,
            let cell = tableView.cellForRow(at: indexPath),
            let id = cellViewModel.selectionData.categoryItemID
            else { return }
        if !viewModel.selectedCategoryItemIDs.contains(id) {
            cell.accessoryType = .checkmark
            viewModel.selectedCategoryItemIDs.append(id)
            addItemHandler?(.init(categoryItemID: id))
        } else {
            cell.accessoryType = .none
            viewModel.selectedCategoryItemIDs.remove(id)
            removeItemHandler?(.init(categoryItemID: id))
        }
    }
}
