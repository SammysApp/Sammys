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
        case constructedItemStackTableViewCell
    }
    
    private struct Constants {
        static let tableViewEstimatedRowHeight: CGFloat = 100
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureTableView()
        configureViewModel()
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
        tableView.register(ConstructedItemStackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.constructedItemStackTableViewCell.rawValue)
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
        tableView.edgesToSuperview()
    }
    
    private func configureViewModel() {
        viewModel.constructedItemStackCellViewModelActions = [
            .configuration: constructedItemStackTableViewCellConfigurationAction
        ]
        viewModel.tableViewSectionModels.bind { sectionModels in
            self.tableViewDataSource.sectionModels = sectionModels
            self.tableViewDelegate.sectionModels = sectionModels
            self.tableView.reloadData()
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - Cell Actions
    private func constructedItemStackTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? OutstandingOrderViewModel.ConstructedItemStackTableViewCellViewModel,
            let cell = data.cell as? ConstructedItemStackTableViewCell else { return }
        cell.nameLabel.text = cellViewModel.configurationData.nameText
        cell.descriptionLabel.text = cellViewModel.configurationData.descriptionText
        cell.priceLabel.text = cellViewModel.configurationData.priceText
        cell.quantityView.counterTextField.text = cellViewModel.configurationData.quantityText
        cell.quantityViewDecrementHandler = { quantityView in
            guard let currentQuantityText = quantityView.counterTextField.text,
                let currentQuantity = Int(currentQuantityText) else { return }
            self.viewModel.beginUpdateConstructedItemQuantityDownload(constructedItemID: cellViewModel.configurationData.constructedItemID, quantity: currentQuantity - 1)
        }
        cell.quantityViewIncrementHandler = { quantityView in
            guard let currentQuantityText = quantityView.counterTextField.text,
                let currentQuantity = Int(currentQuantityText) else { return }
            self.viewModel.beginUpdateConstructedItemQuantityDownload(constructedItemID: cellViewModel.configurationData.constructedItemID, quantity: currentQuantity + 1)
        }
    }
}

private extension OutstandingOrderViewController {
    class ConstructedItemStackTableViewCell: StackTableViewCell {
        let nameLabel = UILabel()
        let descriptionLabel = UILabel()
        let priceLabel = UILabel()
        let quantityView = CounterView()
        
        var quantityViewDecrementHandler: (CounterView) -> Void = { _ in } {
            didSet {
                quantityViewDecrementButtonTouchUpInsideTarget.action =
                    { self.quantityViewDecrementHandler(self.quantityView) }
            }
        }
        var quantityViewIncrementHandler: (CounterView) -> Void = { _ in } {
            didSet {
                quantityViewIncrementButtonTouchUpInsideTarget.action =
                    { self.quantityViewIncrementHandler(self.quantityView) }
            }
        }
        
        private lazy var quantityViewDecrementButtonTouchUpInsideTarget =
            UIControl.Target(action: { self.quantityViewDecrementHandler(self.quantityView) })
        private lazy var quantityViewIncrementButtonTouchUpInsideTarget =
            UIControl.Target(action: { self.quantityViewIncrementHandler(self.quantityView) })
        
        private struct Constants {
            static let quantityViewHeight: CGFloat = 40
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setUp()
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError() }
        
        func setUp() {
            nameLabel.text = "Name"
            
            descriptionLabel.text = "Description"
            descriptionLabel.numberOfLines = 0
            
            quantityView.height(Constants.quantityViewHeight)
            quantityView.decrementButton.add(quantityViewDecrementButtonTouchUpInsideTarget, for: .touchUpInside)
            quantityView.incrementButton.add(quantityViewIncrementButtonTouchUpInsideTarget, for: .touchUpInside)
            
            let leftStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
            leftStackView.axis = .vertical
            
            let rightStackView = UIStackView(arrangedSubviews: [priceLabel])
            rightStackView.axis = .vertical
            
            let splitStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
            
            self.contentStackView.axis = .vertical
            self.contentStackView.addArrangedSubview(splitStackView)
            self.contentStackView.addArrangedSubview(quantityView)
        }
    }
}
