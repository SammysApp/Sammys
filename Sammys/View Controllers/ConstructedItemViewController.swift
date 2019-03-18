//
//  ConstructedItemViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class ConstructedItemViewController: UIViewController {
    let viewModel = ConstructedItemViewModel()
    
    let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let itemsViewController = ItemsViewController()
    private(set) lazy var favoriteBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBar.HeartOutline"), style: .plain, target: favoriteBarButtonItemTarget)
    let bottomRoundedButton = RoundedButton()
    
    private let categoryCollectionViewDataSource = UICollectionViewSectionModelsDataSource()
    private let categoryCollectionViewDelegate = UICollectionViewSectionModelsDelegateFlowLayout()
    
    private lazy var favoriteBarButtonItemTarget = Target(action: favoriteBarButtonItemTargetAction)
    private lazy var bottomRoundedButtonTouchUpInsideTarget = Target(action: bottomRoundedButtonTouchUpInsideAction)
    
    private struct Constants {
        static let categoryCollectionViewInset: CGFloat = 10
        static let categoryCollectionViewHeight: CGFloat = 30
        static let bottomRoundedButtonHeight: CGFloat = 40
        static let bottomRoundedButtonTitleLabelTextFontSize: CGFloat = 18
        static let bottomRoundedButtonTitleLabelText = "Add to Bag"
        static let categoryRoundedTextCollectionViewCellTextLabelFontSize: CGFloat = 12
    }
    
    enum CellIdentifier: String {
        case roundedTextCollectionViewCell
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureNavigation()
        configureCategoryCollectionView()
        configureItemsViewController()
        configureBottomRoundedButton()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        self.view.backgroundColor = .white
        addSubviews()
    }
    
    private func addSubviews() {
        [categoryCollectionView, bottomRoundedButton]
            .forEach { self.view.addSubview($0) }
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
        categoryCollectionView.register(RoundedTextCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.roundedTextCollectionViewCell.rawValue)
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.contentInset.left = Constants.categoryCollectionViewInset
        categoryCollectionView.contentInset.right = Constants.categoryCollectionViewInset
        categoryCollectionView.edgesToSuperview(excluding: .bottom, insets: .top(Constants.categoryCollectionViewInset), usingSafeArea: true)
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
        add(itemsViewController)
        view.sendSubviewToBack(itemsViewController.view)
        itemsViewController.tableView.contentInset.top =
            Constants.categoryCollectionViewHeight + (Constants.categoryCollectionViewInset * 2)
        itemsViewController.tableView.scrollIndicatorInsets.top = itemsViewController.tableView.contentInset.top
        itemsViewController.view.edgesToSuperview(usingSafeArea: true)
    }
    
    private func configureBottomRoundedButton() {
        bottomRoundedButton.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        bottomRoundedButton.titleLabel.textColor = .white
        bottomRoundedButton.titleLabel.font = .systemFont(ofSize: Constants.bottomRoundedButtonTitleLabelTextFontSize, weight: .medium)
        bottomRoundedButton.titleLabel.text = Constants.bottomRoundedButtonTitleLabelText
        bottomRoundedButton.add(bottomRoundedButtonTouchUpInsideTarget, for: .touchUpInside)
        bottomRoundedButton.height(Constants.bottomRoundedButtonHeight)
        bottomRoundedButton.centerX(to: self.view)
        bottomRoundedButton.bottom(to: self.view.safeAreaLayoutGuide)
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
                self.bottomRoundedButton.titleLabel.text = Constants.bottomRoundedButtonTitleLabelText + " " + text
            } else { self.bottomRoundedButton.titleLabel.text = Constants.bottomRoundedButtonTitleLabelText }
        }
        viewModel.isFavorite.bind { value in
            guard let value = value else { return }
            self.favoriteBarButtonItem.image = value ? #imageLiteral(resourceName: "NavBar.Heart") : #imageLiteral(resourceName: "NavBar.HeartOutline")
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - Target Actions
    private func favoriteBarButtonItemTargetAction() {
        if let isFavorite = viewModel.isFavorite.value {
            viewModel.beginFavoriteDownload(isFavorite: !isFavorite)
        }
    }
    
    private func bottomRoundedButtonTouchUpInsideAction() {
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
