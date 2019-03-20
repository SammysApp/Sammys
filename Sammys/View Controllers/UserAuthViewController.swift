//
//  UserAuthViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class UserAuthViewController: UIViewController {
    let viewModel = UserAuthViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let completeButton = RoundedButton()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    enum CellIdentifier: String {
        case textFieldTableViewCell
    }
    
    private struct Constants {
        static let tableViewTableFooterViewHeight: CGFloat = 60
        static let textFieldTableViewCellTitleLabelWidth: CGFloat = 120
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureViewModel()
        configureTableView()
        configureCompleteButton()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: CellIdentifier.textFieldTableViewCell.rawValue)
        tableView.edgesToSuperview()
        let footerView = makeTableViewTableFooterView()
        tableView.tableFooterView = footerView
        let sectionModels = viewModel.makeTableViewSectionModels()
        tableViewDataSource.sectionModels = sectionModels
        tableViewDelegate.sectionModels = sectionModels
        tableView.reloadData()
    }
    
    private func configureCompleteButton() {
        completeButton.backgroundColor = .gray
        completeButton.titleLabel.text = viewModel.completedButtonText
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureViewModel() {
        viewModel.textFieldTableViewCellViewModelActions = [
            .configuration: textFieldTableViewCellConfigurationAction
        ]
    }
    
    // MARK: - Factory Methods
    private func makeTableViewTableFooterView() -> UIView {
        let footerView = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: Constants.tableViewTableFooterViewHeight))
        footerView.addSubview(completeButton)
        completeButton.edgesToSuperview()
        return footerView
    }
    
    // MARK: - Target Actions
    func completeButtonTouchUpInsideAction() {
        viewModel.beginCompleteDownload()
    }
    
    // MARK: - Cell Actions
    private func textFieldTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserAuthViewModel.TextFieldTableViewCellViewModel,
            let cell = data.cell as? TextFieldTableViewCell else { return }
        cell.titleLabelWidth = Constants.textFieldTableViewCellTitleLabelWidth
        cell.titleLabel.text = cellViewModel.configurationData.title
        cell.textFieldTextUpdateHandler = cellViewModel.configurationData.textFieldTextUpdateHandler
    }
}
