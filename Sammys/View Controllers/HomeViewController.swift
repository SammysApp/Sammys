//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()
    
    private let tableView = UITableView()
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case imageCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        configureTableView()
        
        viewModel.categoryImageTableViewCellViewModelActions = [
            .configuration: categoryImageTableViewCellConfigurationHandler,
            .selection: categoryImageTableViewCellSelectionHandler
        ]
        
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        
        viewModel.beginDownloads()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: CellIdentifier.imageCell.rawValue)
        tableView.edgesToSuperview()
    }
    
    private func makeCategoryViewController(parentCategoryID: Category.ID? = nil) -> CategoryViewController {
        let categoryViewController = CategoryViewController()
        categoryViewController.viewModel.parentCategoryID = parentCategoryID
        return categoryViewController
    }
    
    private func categoryImageTableViewCellConfigurationHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel,
            let cell = data.cell as? ImageTableViewCell else { return }
        cell.textLabel.text = cellViewModel.configurationData.text
    }
    
    private func categoryImageTableViewCellSelectionHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel else { return }
        navigationController?.pushViewController(
            makeCategoryViewController(parentCategoryID: cellViewModel.selectionData.id),
            animated: true
        )
    }
}
