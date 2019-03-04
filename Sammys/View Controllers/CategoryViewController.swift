//
//  CategoryViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class CategoryViewController: UIViewController {
    let viewModel = CategoryViewModel()
    
    let tableView = UITableView()
    
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
        viewModel.categoryTableViewCellViewModelActions = [
            .configuration: categoryTableViewCellConfigurationAction,
            .selection: categoryTableViewCellSelectionAction
        ]
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - Factory Methods
    private func makeCategoryViewController(parentCategoryID: Category.ID? = nil) -> CategoryViewController {
        let categoryViewController = CategoryViewController()
        categoryViewController.viewModel.parentCategoryID = parentCategoryID
        return categoryViewController
    }
    
    private func makeItemsViewController(categoryID: Category.ID) -> ItemsViewController {
        let itemsViewController = ItemsViewController()
        itemsViewController.viewModel.categoryID = categoryID
        return itemsViewController
    }
    
    private func makeConstructedItemViewController(categoryID: Category.ID) -> ConstructedItemViewController {
        let constructedItemViewController = ConstructedItemViewController()
        constructedItemViewController.viewModel.categoryID = categoryID
        // Create a new constructed item.
        constructedItemViewController.viewModel.beginCreateConstructedItemDownload()
        return constructedItemViewController
    }
    
    // MARK: - Cell Actions
    private func categoryTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel,
            let cell = data.cell else { return }
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
    
    private func categoryTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel else { return }
        if cellViewModel.selectionData.isConstructable {
            navigationController?.pushViewController(makeConstructedItemViewController(categoryID: cellViewModel.selectionData.id), animated: true)
        } else if let isParentCategory = cellViewModel.selectionData.isParentCategory, isParentCategory {
            navigationController?.pushViewController(makeCategoryViewController(parentCategoryID: cellViewModel.selectionData.id), animated: true)
        } else {
            navigationController?.pushViewController(makeItemsViewController(categoryID: cellViewModel.selectionData.id), animated: true)
        }
    }
}
