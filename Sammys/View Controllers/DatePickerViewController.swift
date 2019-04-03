//
//  DatePickerViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    let viewModel = DatePickerViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DatePickerViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.dateTableViewCellViewModelActions = [
            .configuration: dateTableViewCellConfigurationAction,
            .selection: dateTableViewCellSelectionAction
        ]
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Cell Actions
    private func dateTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? DatePickerViewModel.DateTableViewCellViewModel,
            let cell = data.cell else { return }
        cell.textLabel?.text = cellViewModel.configurationData.text
        cell.accessoryType = cellViewModel.configurationData.isSelected ? .checkmark : .none
    }
    
    private func dateTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? DatePickerViewModel.DateTableViewCellViewModel  else { return }
        viewModel.selectedDate = cellViewModel.selectionData.date
    }
}
