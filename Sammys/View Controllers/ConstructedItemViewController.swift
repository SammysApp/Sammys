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
    private(set) lazy var favoriteBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBar.HeartOutline"), style: .plain, target: favoriteBarButtonItemTarget)
    let completeButton = RoundedButton()
    
    private let categoryCollectionViewDataSource = UICollectionViewSectionModelsDataSource()
    private let categoryCollectionViewDelegate = UICollectionViewSectionModelsDelegateFlowLayout()
    
    private lazy var favoriteBarButtonItemTarget = Target(action: favoriteBarButtonItemTargetAction)
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    private struct Constants {
        static let categoryCollectionViewInset: CGFloat = 10
        static let categoryCollectionViewHeight: CGFloat = 30
        static let completeButtonHeight: CGFloat = 40
        static let completeButtonTitleLabelTextFontSize: CGFloat = 18
        static let completeButtonTitleLabelText = "Add to Bag"
        static let categoryRoundedTextCollectionViewCellTextLabelFontSize: CGFloat = 12
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCategoryCollectionView()
        configureItemsViewController()
        configureCompleteButton()
        configureNavigation()
        setUpView()
        addChildren()
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
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        self.navigationItem.rightBarButtonItem = favoriteBarButtonItem
    }
    
    private func configureCategoryCollectionView() {
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
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
        itemsViewController.addItemHandler = { data in
            self.viewModel.beginAddConstructedItemItemsDownload(categoryItemIDs: [data.categoryItemID])
        }
        itemsViewController.removeItemHandler = { data in
            self.viewModel.beginRemoveConstructedItemItemsDownload(categoryItemID: data.categoryItemID)
        }
        itemsViewController.tableView.contentInset.top =
            Constants.categoryCollectionViewHeight + (Constants.categoryCollectionViewInset * 2)
        itemsViewController.tableView.scrollIndicatorInsets.top = itemsViewController.tableView.contentInset.top
    }
    
    private func configureCompleteButton() {
        completeButton.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        completeButton.titleLabel.textColor = .white
        completeButton.titleLabel.font = .systemFont(ofSize: Constants.completeButtonTitleLabelTextFontSize, weight: .medium)
        completeButton.titleLabel.text = Constants.completeButtonTitleLabelText
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
        completeButton.height(Constants.completeButtonHeight)
    }
    
    private func configureViewModel() {
        let sizeCalculationLabel = UILabel()
        viewModel.categoryRoundedTextCollectionViewCellViewModelActions = [
            .configuration: categoryRoundedTextCollectionViewCellConfigurationAction,
            .selection: categoryRoundedTextCollectionViewCellSelectionAction
        ]
        viewModel.categoryRoundedTextCollectionViewCellViewModelSize = { cellViewModel in
            sizeCalculationLabel.text = cellViewModel.configurationData.text
            return (Double(sizeCalculationLabel.intrinsicContentSize.width) + 20, Double(self.categoryCollectionView.frame.height))
        }
        viewModel.selectedCategoryID.bind { value in
            self.itemsViewController.viewModel.categoryID = value
            self.itemsViewController.viewModel.beginDownloads()
        }
        viewModel.selectedCategoryName.bind { value in
            self.title = value
        }
        viewModel.categoryCollectionViewSectionModels.bind { value in
            self.categoryCollectionViewDataSource.sectionModels = value
            self.categoryCollectionViewDelegate.sectionModels = value
            self.categoryCollectionView.reloadData()
        }
        viewModel.totalPriceText.bind { value in
            if let text = value {
                self.completeButton.titleLabel.text = Constants.completeButtonTitleLabelText + " | " + text
            } else { self.completeButton.titleLabel.text = Constants.completeButtonTitleLabelText }
        }
        viewModel.isFavorite.bind { value in
            guard let value = value else { return }
            self.favoriteBarButtonItem.image = value ? #imageLiteral(resourceName: "NavBar.Heart") : #imageLiteral(resourceName: "NavBar.HeartOutline")
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
        let viewController = UserAuthPageViewController()
        let userDidSignInHandler: (User.ID) -> Void = { id in
            self.viewModel.userID = id
            self.viewModel.beginUpdateConstructedItemUserDownload()
            viewController.dismiss(animated: true, completion: nil)
        }
        viewController.existingUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        viewController.newUserAuthViewController.viewModel.userDidSignInHandler = userDidSignInHandler
        return viewController
    }
    
    // MARK: - Target Actions
    private func favoriteBarButtonItemTargetAction() {
        if let isFavorite = viewModel.isFavorite.value {
            viewModel.beginFavoriteDownload(isFavorite: !isFavorite)
        }
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
        cell.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        cell.textLabel.textColor = .white
        cell.textLabel.font = .systemFont(ofSize: Constants.categoryRoundedTextCollectionViewCellTextLabelFontSize, weight: .bold)
        cell.textLabel.text = cellViewModel.configurationData.text.uppercased()
    }
    
    private func categoryRoundedTextCollectionViewCellSelectionAction(data: UICollectionViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ConstructedItemViewModel.CategoryRoundedTextCollectionViewCellViewModel else { return }
        viewModel.selectedCategoryID.value = cellViewModel.selectionData.categoryID
        viewModel.selectedCategoryName.value = cellViewModel.selectionData.categoryName
    }
}
