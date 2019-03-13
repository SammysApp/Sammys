//
//  OutstandingOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class OutstandingOrderViewController: UIViewController {
    let viewModel = OutstandingOrderViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    enum CellIdentifier: String {
        case stackCell
    }
    
    private struct Constants {
        static let constructedItemStackCellQuantityViewHeight: CGFloat = 40
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
        tableView.register(StackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.stackCell.rawValue)
        tableView.edgesToSuperview()
    }
    
    private func configureViewModel() {
        viewModel.constructedItemStackCellViewModelActions = [
            .configuration: constructedItemStackCellConfigurationAction
        ]
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - Cell Actions
    private func constructedItemStackCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? OutstandingOrderViewModel.ConstructedItemStackCellViewModel,
            let cell = data.cell as? StackTableViewCell else { return }
        let nameLabel = UILabel()
        nameLabel.text = cellViewModel.configurationData.nameText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = cellViewModel.configurationData.priceText
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let quantityView = CounterView()
        quantityView.counterTextField.text = cellViewModel.configurationData.quantityText
        quantityView.height(Constants.constructedItemStackCellQuantityViewHeight)
        
        let leftStackView = UIStackView(arrangedSubviews: [nameLabel])
        leftStackView.axis = .vertical
        
        let rightStackView = UIStackView(arrangedSubviews: [priceLabel])
        rightStackView.axis = .vertical
        
        let splitStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        
        cell.contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cell.contentStackView.axis = .vertical
        cell.contentStackView.addArrangedSubview(splitStackView)
        cell.contentStackView.addArrangedSubview(quantityView)
    }
}
