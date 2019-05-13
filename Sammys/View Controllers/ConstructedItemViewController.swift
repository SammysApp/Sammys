//
//  ConstructedItemViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ConstructedItemViewController: UIViewController {
    let viewModel = ConstructedItemViewModel()
    
    let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let itemsViewController = ItemsViewController()
    
    private(set) lazy var favoriteBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBar.Heart"), style: .plain, target: favoriteBarButtonItemTarget)
    let completeButton = RoundedButton()
    
    let loadingView = BlurLoadingView()
    
    var homeViewController: HomeViewController? {
        return (self.tabBarController?.viewControllers?[homeNavigationViewControllerTabBarControllerIndex] as? UINavigationController)?.viewControllers.first as? HomeViewController
    }
    
    var favoriteConstructedItemsViewController: ConstructedItemsViewController? {
        return (self.tabBarController?.viewControllers?[favoriteConstructedItemsNavigationViewControllerTabBarControllerIndex] as? UINavigationController)?.viewControllers.first as? ConstructedItemsViewController
    }
    
    var outstandingOrderViewController: OutstandingOrderViewController? {
        return (self.tabBarController?.viewControllers?[outstandingOrderNavigationViewControllerTabBarControllerIndex] as? UINavigationController)?.viewControllers.first as? OutstandingOrderViewController
    }
    
    private let categoryCollectionViewDataSource = UICollectionViewSectionModelsDataSource()
    private let categoryCollectionViewDelegate = UICollectionViewSectionModelsDelegate()
    
    private lazy var favoriteBarButtonItemTarget = Target(action: favoriteBarButtonItemAction)
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    private struct Constants {
        static let loadingViewHeight = CGFloat(100)
        static let loadingViewWidth = CGFloat(100)
        
        static let categoryCollectionViewInset = CGFloat(10)
        static let categoryCollectionViewHeight = CGFloat(40)
        
        static let categoryRoundedTextCollectionViewCellBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        static let categoryRoundedTextCollectionViewCellTextLabelTextColor = UIColor.white
        static let categoryRoundedTextCollectionViewCellTextLabelFontSize = CGFloat(12)
        static let categoryRoundedTextCollectionViewCellTextLabelFontWeight = UIFont.Weight.bold
        
        static let favoriteBarButtonItemDefaultColor = UIColor.lightGray
        static let favoriteBarButtonItemSelectedColor = #colorLiteral(red: 1, green: 0, blue: 0.2615994811, alpha: 1)
        
        static let completeButtonDisabledBackgroundColor = UIColor.lightGray
        static let completeButtonEnabledBackgroundColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        static let completeButtonTitleLabelTextColor = UIColor.white
        static let completeButtonTitleLabelTextFontSize = CGFloat(20)
        static let completeButtonTitleLabelFontWeight = UIFont.Weight.semibold
        static let completeButtonTitleLabelText = "Add to Bag"
        static let completeButtonHeight = CGFloat(60)
        static let completeButtonHorizontalInset = CGFloat(10)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCategoryCollectionView()
        configureItemsViewController()
        configureCompleteButton()
        configureLoadingView()
        setUpView()
        addChildren()
        configureNavigation()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        self.view.backgroundColor = .white
        addSubviews()
    }
    
    private func addSubviews() {
        [categoryCollectionView, completeButton, loadingView]
            .forEach { self.view.addSubview($0) }
        
        categoryCollectionView.edgesToSuperview(excluding: .bottom, insets: .top(Constants.categoryCollectionViewInset), usingSafeArea: true)
        
        completeButton.height(Constants.completeButtonHeight)
        completeButton.edgesToSuperview(excluding: .top, insets: .init(top: 0, left: Constants.completeButtonHorizontalInset, bottom: 0, right: Constants.completeButtonHorizontalInset), usingSafeArea: true)
        
        loadingView.centerInSuperview()
        loadingView.height(Constants.loadingViewHeight)
        loadingView.width(Constants.loadingViewWidth)
    }
    
    private func addChildren() {
        add(itemsViewController)
        view.sendSubviewToBack(itemsViewController.view)
        itemsViewController.view.topToSuperview(usingSafeArea: true)
        itemsViewController.view.edgesToSuperview(excluding: .top)
    }
    
    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = favoriteBarButtonItem
    }
    
    private func configureCategoryCollectionView() {
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        categoryCollectionView.dataSource = categoryCollectionViewDataSource
        categoryCollectionView.delegate = categoryCollectionViewDelegate
        categoryCollectionView.register(RoundedTextCollectionViewCell.self, forCellWithReuseIdentifier: ConstructedItemViewModel.CellIdentifier.roundedTextCollectionViewCell.rawValue)
        
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.contentInset.left = Constants.categoryCollectionViewInset
        categoryCollectionView.contentInset.right = Constants.categoryCollectionViewInset
        categoryCollectionView.height(Constants.categoryCollectionViewHeight)
    }
    
    private func configureItemsViewController() {
        itemsViewController.viewModel.httpClient = viewModel.httpClient
        
        itemsViewController.viewModel.addItemHandler = { categoryItemID in
            self.viewModel.beginAddConstructedItemItemsDownload(categoryItemIDs: [categoryItemID])
        }
        itemsViewController.viewModel.removeItemHandler = { categoryItemID in
            self.viewModel.beginRemoveConstructedItemItemDownload(categoryItemID: categoryItemID)
        }
        
        itemsViewController.tableView.contentInset.top =
            Constants.categoryCollectionViewHeight + (Constants.categoryCollectionViewInset * 2)
        itemsViewController.tableView.scrollIndicatorInsets.top = itemsViewController.tableView.contentInset.top
        
        itemsViewController.tableView.contentInset.bottom = Constants.completeButtonHeight
    }
    
    private func configureCompleteButton() {
        completeButton.titleLabel.textColor = Constants.completeButtonTitleLabelTextColor
        completeButton.titleLabel.font = .systemFont(ofSize: Constants.completeButtonTitleLabelTextFontSize, weight: Constants.completeButtonTitleLabelFontWeight)
        
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureLoadingView() {
        loadingView.image = #imageLiteral(resourceName: "Loading.Bagel")
    }
    
    private func configureViewModel() {
        viewModel.categoryRoundedTextCollectionViewCellViewModelActions = [
            .configuration: categoryRoundedTextCollectionViewCellConfigurationAction,
            .selection: categoryRoundedTextCollectionViewCellSelectionAction
        ]
        
        viewModel.selectedCategoryID.bindAndRun { value in
            guard let id = value else { return }
            self.itemsViewController.viewModel.categoryID = id
            self.itemsViewController.viewModel.beginDownloads() {
                self.itemsViewController.tableView.scrollToTop(animated: false)
            }
        }
        viewModel.selectedCategoryName.bindAndRun { value in
            guard let name = value else { return }
            self.title = "Choose \(name)"
        }
        
        viewModel.totalPriceText.bindAndRun { value in
            if let text = value {
                self.completeButton.titleLabel.text = Constants.completeButtonTitleLabelText + " | " + text
            } else { self.completeButton.titleLabel.text = Constants.completeButtonTitleLabelText }
        }
        viewModel.isFavorite.bindAndRun { value in
            self.favoriteBarButtonItem.tintColor = value ? Constants.favoriteBarButtonItemSelectedColor : Constants.favoriteBarButtonItemDefaultColor
        }
        viewModel.isOutstandingOrderAddable.bindAndRun { value in
            self.completeButton.backgroundColor = value ? Constants.completeButtonEnabledBackgroundColor : Constants.completeButtonDisabledBackgroundColor
            self.completeButton.isEnabled = value
        }
        
        viewModel.categoryCollectionViewSectionModels.bindAndRun { value in
            self.categoryCollectionViewDataSource.sectionModels = value
            self.categoryCollectionViewDelegate.sectionModels = value
            self.categoryCollectionView.reloadData()
        }
        
        viewModel.selectedCategoryItemIDs.bindAndRun { value in
            self.itemsViewController.viewModel.selectedCategoryItemIDs = value
        }
        
        viewModel.isLoading.bindAndRun { value in
            self.view.isUserInteractionEnabled = !value
            if value { self.loadingView.startAnimating() }
            else { self.loadingView.stopAnimating() }
        }
        
        viewModel.errorHandler = { error in
            switch error {
            case UserAuthManagerError.noCurrentUser:
                self.present(UINavigationController(rootViewController: self.makeUserAuthPageViewController()), animated: true, completion: nil)
            default: print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Factory Methods
    private func makeUserAuthPageViewController() -> UserAuthPageViewController {
        let userAuthPageViewController = UserAuthPageViewController()
        
        userAuthPageViewController.didCancelHandler = {
            self.dismiss(animated: true, completion: nil)
        }
        
        let userDidSignInHandler: (User.ID) -> Void = { id in
            self.viewModel.userID = id
            self.viewModel.beginUpdateConstructedItemUserDownload()
            
            self.homeViewController?.viewModel.userID = id
            self.homeViewController?.beginDownloads()
            
            self.favoriteConstructedItemsViewController?.viewModel.userID = id
            self.favoriteConstructedItemsViewController?.beginDownloads()
            
            self.outstandingOrderViewController?.viewModel.userID = id
            self.outstandingOrderViewController?.beginDownloads()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        userAuthPageViewController.existingUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        userAuthPageViewController.newUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        return userAuthPageViewController
    }
    
    // MARK: - Target Actions
    private func favoriteBarButtonItemAction() {
        viewModel.beginUpdateConstructedItemDownload(isFavorite: !viewModel.isFavorite.value) {
            self.favoriteConstructedItemsViewController?.beginDownloads()
        }
    }
    
    private func completeButtonTouchUpInsideAction() {
        viewModel.beginAddToOutstandingOrderDownload() {
            if let outstandingOrderViewController = self.outstandingOrderViewController {
                outstandingOrderViewController.navigationController?.showEmptyBadge()
                outstandingOrderViewController.beginDownloads()
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Cell Actions
    private func categoryRoundedTextCollectionViewCellConfigurationAction(data: UICollectionViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ConstructedItemViewModel.CategoryRoundedTextCollectionViewCellViewModel,
            let cell = data.cell as? RoundedTextCollectionViewCell else { return }
        
        cell.backgroundColor = Constants.categoryRoundedTextCollectionViewCellBackgroundColor
        cell.textLabel.textColor = Constants.categoryRoundedTextCollectionViewCellTextLabelTextColor
        cell.textLabel.font = .systemFont(ofSize: Constants.categoryRoundedTextCollectionViewCellTextLabelFontSize, weight: Constants.categoryRoundedTextCollectionViewCellTextLabelFontWeight)
        cell.textLabel.text = cellViewModel.configurationData.text.uppercased()
    }
    
    private func categoryRoundedTextCollectionViewCellSelectionAction(data: UICollectionViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ConstructedItemViewModel.CategoryRoundedTextCollectionViewCellViewModel else { return }
        
        viewModel.selectedCategoryID.value = cellViewModel.selectionData.categoryID
        viewModel.selectedCategoryName.value = cellViewModel.selectionData.categoryName
        
        viewModel.beginSelectedCategoryItemIDsDownload()
    }
}
