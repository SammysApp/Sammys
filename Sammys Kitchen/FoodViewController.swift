//
//  FoodViewController.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController {
    var food: Food? {
        didSet {
            if let food = food { updateCollectionView(with: food) }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: FoodCollectionView! {
        didSet {
            if let food = food { updateCollectionView(with: food) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    func updateCollectionView(with food: Food) {
        let viewModel = FoodCollectionViewModel(food: food)
        viewModel.showsEdit = false
        viewModel.showPrices = false
        viewModel.numberOfCellsPerRow = 4
        viewModel.cellSpacing = 20
        collectionView?.viewModel = viewModel
    }
}

