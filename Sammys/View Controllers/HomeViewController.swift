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
    private let viewModel = HomeViewModel()
    
    private let tableView = UITableView()
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case imageCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.categoryImageTableViewCellViewModelActions = [
            .configuration: categoryImageTableViewCellConfigurationHandler,
            .selection: categoryImageTableViewCellSelectionHandler
        ]
        
        [tableView]
            .forEach { self.view.addSubview($0) }
        
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: CellIdentifier.imageCell.rawValue)
        tableView.edgesToSuperview()
        
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        
        viewModel.beginCategoriesDownload()
    }
    
    private func categoryImageTableViewCellConfigurationHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel,
            let cell = data.cell as? ImageTableViewCell else { return }
        cell.textLabel.text = cellViewModel.configurationData.text
    }
    
    private func categoryImageTableViewCellSelectionHandler(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel else { return }
    }
}
