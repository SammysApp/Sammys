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
    
    private let itemsViewController = ItemsViewController()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        configureItemsViewController()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func configureItemsViewController() {
        add(itemsViewController)
        itemsViewController.view.edgesToSuperview()
    }
    
    private func configureViewModel() {
        viewModel.selectedCategoryID.bind { id in
            self.itemsViewController.viewModel.categoryID = id
            self.itemsViewController.viewModel.beginDownloads()
        }
        viewModel.beginDownloads()
    }
}
