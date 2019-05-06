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
    
    let loadingView = BlurLoadingView()
    
    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: tapGestureRecognizerTarget)
    
    var homeViewController: HomeViewController? {
        return (self.tabBarController?.viewControllers?[homeNavigationViewControllerTabBarControllerIndex] as? UINavigationController)?.viewControllers.first as? HomeViewController
    }
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var tapGestureRecognizerTarget = Target(action: tapGestureRecognizerAction)
    
    private struct Constants {
        static let navigationBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let loadingViewHeight = CGFloat(100)
        static let loadingViewWidth = CGFloat(100)
        
        static let tableViewEstimatedRowHeight = CGFloat(100)
        
        static let itemTableViewCellTitleLabelFontWeight = UIFont.Weight.medium
        static let itemTableViewCellDescriptionLabelTextColor = UIColor.lightGray
        static let itemTableViewCellQuantityViewCounterTextFieldTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        static let itemTableViewCellQuantityViewButtonsBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        static let itemTableViewCellQuantityViewButtonsImageColor = UIColor.white
        
        static let checkoutSheetViewControllerViewBackgroundColor = UIColor.white
        static let checkoutSheetViewControllerViewLayerBorderColor = UIColor.lightGray.cgColor
        static let checkoutSheetViewControllerViewLayerBorderWidth = CGFloat(0.5)
        static let checkoutSheetViewControllerViewLayerCornerRadius = CGFloat(25)
        static let checkoutSheetViewControllerViewHeight = CGFloat(140)
        static let checkoutSheetCheckoutButtonTitleLabelDefaultText = "Checkout"
        static let checkoutSheetCheckoutButtonTitleLabelSignInText = "Sign In to Checkout"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureCheckoutSheetViewController()
        configureLoadingView()
        configureTapGestureRecognizer()
        setUpView()
        addChildren()
        configureNavigation()
        configureViewModel()
        
        beginDownloads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.delegate = self
        self.clearBadge()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tabBarController?.delegate = nil
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func addSubviews() {
        [tableView, loadingView]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        
        loadingView.centerInSuperview()
        loadingView.height(Constants.loadingViewHeight)
        loadingView.width(Constants.loadingViewWidth)
    }
    
    private func addChildren() {
        self.add(checkoutSheetViewController)
        checkoutSheetViewController.view.height(Constants.checkoutSheetViewControllerViewHeight)
        checkoutSheetViewController.view.edgesToSuperview(excluding: .top, insets: .init(top: 0, left: -Constants.checkoutSheetViewControllerViewLayerBorderWidth, bottom: -Constants.checkoutSheetViewControllerViewLayerBorderWidth, right: -Constants.checkoutSheetViewControllerViewLayerBorderWidth), usingSafeArea: true)
    }
    
    private func configureNavigation() {
        self.navigationController?.navigationBar.tintColor = Constants.navigationBarTintColor
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: OutstandingOrderViewModel.CellIdentifier.itemTableViewCell.rawValue)
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
    }
    
    private func configureCheckoutSheetViewController() {
        checkoutSheetViewController.view.backgroundColor = Constants.checkoutSheetViewControllerViewBackgroundColor
        checkoutSheetViewController.view.layer.borderColor = Constants.checkoutSheetViewControllerViewLayerBorderColor
        checkoutSheetViewController.view.layer.borderWidth = Constants.checkoutSheetViewControllerViewLayerBorderWidth
        checkoutSheetViewController.view.layer.cornerRadius = Constants.checkoutSheetViewControllerViewLayerCornerRadius
        checkoutSheetViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        checkoutSheetViewController.checkoutButtonTouchUpInsideHandler = {
            if self.viewModel.isUserIDSet.value {
                self.navigationController?.pushViewController(self.makeCheckoutViewController(), animated: true)
            } else {
                self.present(UINavigationController(rootViewController: self.makeUserAuthPageViewController()), animated: true, completion: nil)
            }
        }
        
        checkoutSheetViewController.view.isHidden = true
    }
    
    private func configureLoadingView() {
        loadingView.image = #imageLiteral(resourceName: "Loading.Bagel")
    }
    
    private func configureTapGestureRecognizer() {
        tapGestureRecognizer.isEnabled = false
    }
    
    private func configureViewModel() {
        viewModel.itemCellViewModelActions = [
            .configuration: itemTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.taxPriceText.bindAndRun { self.checkoutSheetViewController.taxPriceLabel.text = $0 }
        viewModel.subtotalPriceText.bindAndRun { self.checkoutSheetViewController.subtotalPriceLabel.text = $0 }
        
        viewModel.isItemsEmpty.bindAndRun { value in
            guard let isItemsEmpty = value else { return }
            if isItemsEmpty { self.setUpForEmptyItems() }
            else { self.setUpForNonEmptyItems() }
        }
        
        viewModel.isUserIDSet.bindAndRun { value in
            self.checkoutSheetViewController.checkoutButton.titleLabel.text = value ? Constants.checkoutSheetCheckoutButtonTitleLabelDefaultText : Constants.checkoutSheetCheckoutButtonTitleLabelSignInText
        }
        
        viewModel.isLoading.bindAndRun { value in
            self.view.isUserInteractionEnabled = !value
            if value { self.loadingView.startAnimating() }
            else { self.loadingView.stopAnimating() }
        }
        
        viewModel.errorHandler = { value in
            switch value {
            default: print(value.localizedDescription)
            }
        }
    }
    
    private func setUpForNonEmptyItems() {
        checkoutSheetViewController.view.isHidden = false
    }
    
    private func setUpForEmptyItems() {
        checkoutSheetViewController.view.isHidden = true
    }
    
    // MARK: - Methods
    func beginDownloads() {
        if viewModel.isUserSignedIn {
            viewModel.beginUserIDDownload {
                self.viewModel.beginDownloads()
            }
        } else { viewModel.beginDownloads() }
    }
    
    func clear() {
        self.navigationController?.clearBadge()
        viewModel.clear()
    }
    
    // MARK: - Factory Methods
    private func makeUserAuthPageViewController() -> UserAuthPageViewController {
        let userAuthPageViewController = UserAuthPageViewController()
        userAuthPageViewController.didCancelHandler = {
            self.dismiss(animated: true, completion: nil)
        }
        
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
        
        checkoutViewController.didCreatePurchasedOrderHandler = { id in
            self.clear()
            self.homeViewController?.beginDownloads()
            checkoutViewController.present(UINavigationController(rootViewController: self.makePurchasedOrderViewController(purchasedOrderID: id)), animated: true) {
                self.navigationController?.popViewController(animated: false)
            }
        }
        return checkoutViewController
    }
    
    private func makePurchasedOrderViewController(purchasedOrderID: PurchasedOrder.ID) -> PurchasedOrderViewController {
        let purchasedOrderViewController = PurchasedOrderViewController()
        purchasedOrderViewController.viewModel.purchasedOrderID = purchasedOrderID
        return purchasedOrderViewController
    }
    
    // MARK: - Target Actions
    private func tapGestureRecognizerAction() {
        self.view.endEditing(true)
        tapGestureRecognizer.isEnabled = false
    }
    
    // MARK: - Cell Actions
    private func itemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? OutstandingOrderViewModel.ItemTableViewCellViewModel,
            let cell = data.cell as? ItemTableViewCell else { return }
        
        cell.selectionStyle = .none
        
        cell.titleLabel.font = .systemFont(ofSize: cell.titleLabel.font.pointSize, weight: Constants.itemTableViewCellTitleLabelFontWeight)
        cell.titleLabel.text = cellViewModel.configurationData.titleText
        
        cell.descriptionLabel.textColor = Constants.itemTableViewCellDescriptionLabelTextColor
        cell.descriptionLabel.text = cellViewModel.configurationData.descriptionText
        
        cell.priceLabel.text = cellViewModel.configurationData.priceText
        
        cell.quantityView.counterTextField.tintColor = Constants.itemTableViewCellQuantityViewCounterTextFieldTintColor
        cell.quantityView.counterTextField.text = cellViewModel.configurationData.quantityText
        cell.quantityView.counterTextField.delegate = self
        
        cell.quantityViewButtonsBackgroundColor = Constants.itemTableViewCellQuantityViewButtonsBackgroundColor
        cell.quantityViewButtonsImageColor = Constants.itemTableViewCellQuantityViewButtonsImageColor
        
        cell.quantityViewTextFieldTextUpdateHandler = { quantityView in
            guard let quantityText = quantityView.counterTextField.text,
                let quantity = Int(quantityText) else { return }
            
            self.viewModel.beginUpdateConstructedItemQuantityDownload(constructedItemID: cellViewModel.configurationData.constructedItemID, quantity: quantity)
        }
        
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

extension OutstandingOrderViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Show badge if changing view controllers and there are items.
        if viewController != self.navigationController && viewModel.isItemsEmpty.value == false {
            self.showEmptyBadge()
        }
    }
}

extension OutstandingOrderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapGestureRecognizer.isEnabled = true
    }
}
