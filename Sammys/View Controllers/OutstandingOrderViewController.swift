//
//  OutstandingOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class OutstandingOrderViewController: UIViewController {
    let viewModel = OutstandingOrderViewModel()
    
    let tableView = UITableView()
    let checkoutSheetViewController = CheckoutSheetViewController()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private struct Constants {
        static let tableViewEstimatedRowHeight = CGFloat(100)
        
        static let checkoutSheetViewControllerViewBackgroundColor = UIColor.white
        static let checkoutSheetViewControllerViewHeight = CGFloat(120)
        static let checkoutSheetCheckoutButtonTitleLabelDefaultText = "Checkout"
        static let checkoutSheetCheckoutButtonTitleLabelSignInText = "Sign In to Checkout"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureCheckoutSheetViewController()
        setUpView()
        addChildren()
        configureViewModel()
        
        if viewModel.isUserSignedIn {
            viewModel.beginUserIDDownload {
                self.viewModel.beginDownloads()
            }
        } else { viewModel.beginDownloads() }
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
    }
    
    private func addChildren() {
        self.add(checkoutSheetViewController)
        checkoutSheetViewController.view.height(Constants.checkoutSheetViewControllerViewHeight)
        checkoutSheetViewController.view.edgesToSuperview(excluding: .top, usingSafeArea: true)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ItemStackTableViewCell.self, forCellReuseIdentifier: OutstandingOrderViewModel.CellIdentifier.itemStackTableViewCell.rawValue)
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
    }
    
    private func configureCheckoutSheetViewController() {
        checkoutSheetViewController.view.backgroundColor = Constants.checkoutSheetViewControllerViewBackgroundColor
        checkoutSheetViewController.checkoutButtonTouchUpInsideHandler = {
            if self.viewModel.isUserSet.value {
                self.navigationController?.pushViewController(self.makeCheckoutViewController(), animated: true)
            } else {
                self.present(UINavigationController(rootViewController: self.makeUserAuthPageViewController()), animated: true, completion: nil)
            }
        }
    }
    
    private func configureViewModel() {
        viewModel.constructedItemStackCellViewModelActions = [
            .configuration: constructedItemStackTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.taxPriceText.bindAndRun { self.checkoutSheetViewController.taxPriceLabel.text = $0 }
        viewModel.subtotalPriceText.bindAndRun { self.checkoutSheetViewController.subtotalPriceLabel.text = $0 }
        
        viewModel.isUserSet.bindAndRun { value in
            self.checkoutSheetViewController.checkoutButton.titleLabel.text = value ? Constants.checkoutSheetCheckoutButtonTitleLabelDefaultText : Constants.checkoutSheetCheckoutButtonTitleLabelSignInText
        }
        
        viewModel.errorHandler = { value in
            switch value {
            default: print(value.localizedDescription)
            }
        }
    }
    
    // MARK: - Factory Methods
    private func makeUserAuthPageViewController() -> UserAuthPageViewController {
        let userAuthPageViewController = UserAuthPageViewController()
        
        let userDidSignInHandler: (User.ID) -> Void = { id in
            self.viewModel.userID = id
            self.viewModel.beginUpdateOutstandingOrderUserDownload() {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        userAuthPageViewController.existingUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        userAuthPageViewController.newUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        return userAuthPageViewController
    }
    
    private func makeCheckoutViewController() -> CheckoutViewController {
        let checkoutViewController = CheckoutViewController()
        checkoutViewController.hidesBottomBarWhenPushed = true
        checkoutViewController.viewModel.outstandingOrderID = viewModel.outstandingOrderID
        checkoutViewController.viewModel.userID = viewModel.userID
        return checkoutViewController
    }
    
    // MARK: - Cell Actions
    private func constructedItemStackTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? OutstandingOrderViewModel.ConstructedItemStackTableViewCellViewModel,
            let cell = data.cell as? ItemStackTableViewCell else { return }
        
        cell.nameLabel.text = cellViewModel.configurationData.nameText
        cell.descriptionLabel.text = cellViewModel.configurationData.descriptionText
        cell.priceLabel.text = cellViewModel.configurationData.priceText
        cell.quantityView.counterTextField.text = cellViewModel.configurationData.quantityText
        
        cell.quantityViewDidDecrementHandler = { quantityView in
            guard let currentQuantityText = quantityView.counterTextField.text,
                let currentQuantity = Int(currentQuantityText) else { return }
            
            self.viewModel.beginUpdateConstructedItemQuantityDownload(constructedItemID: cellViewModel.configurationData.constructedItemID, quantity: currentQuantity - 1)
        }
        cell.quantityViewDidIncrementHandler = { quantityView in
            guard let currentQuantityText = quantityView.counterTextField.text,
                let currentQuantity = Int(currentQuantityText) else { return }
            
            self.viewModel.beginUpdateConstructedItemQuantityDownload(constructedItemID: cellViewModel.configurationData.constructedItemID, quantity: currentQuantity + 1)
        }
    }
}

private extension OutstandingOrderViewController {
    class ItemStackTableViewCell: StackTableViewCell {
        let nameLabel = UILabel()
        let descriptionLabel = UILabel()
        let priceLabel = UILabel()
        let quantityView = CounterView()
        
        var quantityViewDidDecrementHandler: (CounterView) -> Void = { _ in } {
            didSet {
                quantityViewDecrementButtonTouchUpInsideTarget.action =
                    { self.quantityViewDidDecrementHandler(self.quantityView) }
            }
        }
        var quantityViewDidIncrementHandler: (CounterView) -> Void = { _ in } {
            didSet {
                quantityViewIncrementButtonTouchUpInsideTarget.action =
                    { self.quantityViewDidIncrementHandler(self.quantityView) }
            }
        }
        
        private lazy var quantityViewDecrementButtonTouchUpInsideTarget =
            Target { self.quantityViewDidDecrementHandler(self.quantityView) }
        private lazy var quantityViewIncrementButtonTouchUpInsideTarget =
            Target { self.quantityViewDidIncrementHandler(self.quantityView) }
        
        private struct Constants {
            static let quantityViewHeight = CGFloat(40)
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
