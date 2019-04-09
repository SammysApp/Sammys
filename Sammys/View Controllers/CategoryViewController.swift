//
//  CategoryViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    let viewModel = CategoryViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private struct Constants {
        static let categoryTableViewCellTextLabelFontSize = CGFloat(18)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CategoryViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.categoryTableViewCellViewModelActions = [
            .configuration: categoryTableViewCellConfigurationAction,
            .selection: categoryTableViewCellSelectionAction
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
    
    // MARK: - Factory Methods
    private func makeCategoryViewController(parentCategoryID: Category.ID? = nil, title: String? = nil) -> CategoryViewController {
        let categoryViewController = CategoryViewController()
        categoryViewController.title = title
        categoryViewController.viewModel.parentCategoryID = parentCategoryID
        return categoryViewController
    }
    
    private func makeItemsViewController(categoryID: Category.ID, title: String? = nil) -> ItemsViewController {
        let itemsViewController = ItemsViewController()
        itemsViewController.title = title
        itemsViewController.viewModel.categoryID = categoryID
        return itemsViewController
    }
    
    private func makeConstructedItemViewController(categoryID: Category.ID, title: String? = nil) -> ConstructedItemViewController {
        let constructedItemViewController = ConstructedItemViewController()
        
        constructedItemViewController.title = title
        constructedItemViewController.hidesBottomBarWhenPushed = true
        
        constructedItemViewController.viewModel.categoryID = categoryID
        // Create a new constructed item after downloading potential signed in user.
        if constructedItemViewController.viewModel.isUserSignedIn {
            constructedItemViewController.viewModel.beginUserIDDownload {
                constructedItemViewController.viewModel.beginCreateConstructedItemDownload()
            }
        } else { constructedItemViewController.viewModel.beginCreateConstructedItemDownload() }
        
        return constructedItemViewController
    }
    
    // MARK: - Cell Actions
    private func categoryTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.font = .systemFont(ofSize: Constants.categoryTableViewCellTextLabelFontSize)
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
    
    private func categoryTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel else { return }
        
        let id = cellViewModel.selectionData.id
        let title = cellViewModel.selectionData.title
        
        if cellViewModel.selectionData.isConstructable {
            navigationController?
                .pushViewController(makeConstructedItemViewController(categoryID: id, title: title), animated: true)
        } else if let isParentCategory = cellViewModel.selectionData.isParentCategory, isParentCategory {
            navigationController?
                .pushViewController(makeCategoryViewController(parentCategoryID: id, title: title), animated: true)
        } else {
            navigationController?.pushViewController(makeItemsViewController(categoryID: id, title: title), animated: true)
        }
    }
}
