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
    
    private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let categoryCollectionViewDataSource = UICollectionViewSectionModelsDataSource()
    private let categoryCollectionViewDelegate = UICollectionViewSectionModelsDelegateFlowLayout()
    private let itemsViewController = ItemsViewController()
    
    enum CellIdentifier: String {
        case roundedTextCell
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        addSubviews()
        configureCategoryCollectionView()
        configureItemsViewController()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [categoryCollectionView]
            .forEach { self.view.addSubview($0) }
    }
    
    private func configureCategoryCollectionView() {
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        categoryCollectionView.dataSource = categoryCollectionViewDataSource
        categoryCollectionView.delegate = categoryCollectionViewDelegate
        categoryCollectionView.register(RoundedTextCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.roundedTextCell.rawValue)
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        categoryCollectionView.height(60)
    }
    
    private func configureItemsViewController() {
        add(itemsViewController)
        itemsViewController.view.edgesToSuperview(excluding: .top)
        itemsViewController.view.topToBottom(of: categoryCollectionView)
    }
    
    private func configureViewModel() {
        let sizeCalculationLabel = UILabel()
        viewModel.categoryRoundedTextCollectionViewCellViewModelActions = [
            .configuration: categoryRoundedTextCollectionViewCellConfigurationAction
        ]
        viewModel.categoryRoundedTextCollectionViewCellViewModelSize = { cellViewModel in
            sizeCalculationLabel.text = cellViewModel.configurationData.text
            return (Double(sizeCalculationLabel.intrinsicContentSize.width), Double(self.categoryCollectionView.frame.height))
        }
        viewModel.selectedCategoryID.bind { id in
            self.itemsViewController.viewModel.categoryID = id
            self.itemsViewController.viewModel.beginDownloads()
        }
        viewModel.categoryCollectionViewSectionModels.bind { sectionModels in
            self.categoryCollectionViewDataSource.sectionModels = sectionModels
            self.categoryCollectionViewDelegate.sectionModels = sectionModels
            self.categoryCollectionView.reloadData()
        }
        viewModel.beginDownloads()
    }
    
    // MARK: - UITableViewCellViewModel Actions
    private func categoryRoundedTextCollectionViewCellConfigurationAction(data: UICollectionViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ConstructedItemViewModel.CategoryRoundedTextCollectionViewCellViewModel,
            let cell = data.cell as? RoundedTextCollectionViewCell else { return }
        cell.textLabel.text = cellViewModel.configurationData.text
    }
}
