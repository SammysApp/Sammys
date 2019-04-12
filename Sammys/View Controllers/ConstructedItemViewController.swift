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
    
    private let categoryCollectionViewDataSource = UICollectionViewSectionModelsDataSource()
    private let categoryCollectionViewDelegate = UICollectionViewSectionModelsDelegate()
    
    private lazy var favoriteBarButtonItemTarget = Target(action: favoriteBarButtonItemAction)
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    private struct Constants {
        static let categoryCollectionViewInset = CGFloat(10)
        static let categoryCollectionViewHeight = CGFloat(40)
        
        static let categoryRoundedTextCollectionViewCellBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        static let categoryRoundedTextCollectionViewCellTextLabelTextColor = UIColor.white
        static let categoryRoundedTextCollectionViewCellTextLabelFontWeight = UIFont.Weight.bold
        static let categoryRoundedTextCollectionViewCellTextLabelFontSize = CGFloat(12)
        
        static let favoriteBarButtonItemDefaultColor = UIColor.lightGray
        static let favoriteBarButtonItemSelectedColor = #colorLiteral(red: 1, green: 0, blue: 0.2615994811, alpha: 1)
        
        static let completeButtonDisabledBackgroundColor = UIColor.lightGray
        static let completeButtonEnabledBackgroundColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        static let completeButtonTitleLabelTextColor = UIColor.white
        static let completeButtonTitleLabelFontWeight = UIFont.Weight.semibold
        static let completeButtonTitleLabelTextFontSize = CGFloat(18)
        static let completeButtonTitleLabelText = "Add to Bag"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCategoryCollectionView()
        configureItemsViewController()
        configureCompleteButton()
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
        [categoryCollectionView, completeButton]
            .forEach { self.view.addSubview($0) }
        categoryCollectionView.edgesToSuperview(excluding: .bottom, insets: .top(Constants.categoryCollectionViewInset), usingSafeArea: true)
        completeButton.centerX(to: self.view)
        completeButton.bottom(to: self.view.safeAreaLayoutGuide)
    }
    
    private func addChildren() {
        add(itemsViewController)
        view.sendSubviewToBack(itemsViewController.view)
        itemsViewController.view.edgesToSuperview(usingSafeArea: true)
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
    }
    
    private func configureCompleteButton() {
        completeButton.titleLabel.textColor = Constants.completeButtonTitleLabelTextColor
        completeButton.titleLabel.font = .systemFont(ofSize: Constants.completeButtonTitleLabelTextFontSize, weight: Constants.completeButtonTitleLabelFontWeight)
        
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureViewModel() {
        viewModel.categoryRoundedTextCollectionViewCellViewModelActions = [
            .configuration: categoryRoundedTextCollectionViewCellConfigurationAction,
            .selection: categoryRoundedTextCollectionViewCellSelectionAction
        ]
        
        viewModel.selectedCategoryID.bindAndRun { value in
            guard let id = value else { return }
            self.itemsViewController.viewModel.categoryID = id
            self.itemsViewController.viewModel.beginDownloads()
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
        let userDidSignInHandler: (User.ID) -> Void = { id in
            self.viewModel.userID = id
            self.viewModel.beginUpdateConstructedItemUserDownload()
            userAuthPageViewController.dismiss(animated: true, completion: nil)
        }
        userAuthPageViewController.existingUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        userAuthPageViewController.newUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        return userAuthPageViewController
    }
    
    // MARK: - Target Actions
    private func favoriteBarButtonItemAction() {
        viewModel.beginUpdateConstructedItemDownload(isFavorite: !viewModel.isFavorite.value)
    }
    
    private func completeButtonTouchUpInsideAction() {
        viewModel.beginAddToOutstandingOrderDownload() {
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
