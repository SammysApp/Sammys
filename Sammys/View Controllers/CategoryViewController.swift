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
    
    private let tableView = UITableView()
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        configureTableView()
        
        viewModel.categoryTableViewCellViewModelActions = [
            .configuration: categoryTableViewCellConfigurationHandler,
            .selection: categoryTableViewCellSelectionHandler
        ]
        
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        
        viewModel.beginCategoriesDownload()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.cell.rawValue)
        tableView.edgesToSuperview()
    }
    
    private func makeCategoryViewController(parentCategoryID: Category.ID? = nil) -> CategoryViewController {
        let categoryViewController = CategoryViewController()
        categoryViewController.viewModel.parentCategoryID = parentCategoryID
        return categoryViewController
    }
    
    private func categoryTableViewCellConfigurationHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel,
            let cell = data.cell else { return }
        cell.textLabel?.text = cellViewModel.configurationData.text
    }
    
    private func categoryTableViewCellSelectionHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CategoryViewModel.CategoryTableViewCellViewModel else { return }
        navigationController?.pushViewController(
            makeCategoryViewController(parentCategoryID: cellViewModel.selectionData.id),
            animated: true
        )
    }
}
