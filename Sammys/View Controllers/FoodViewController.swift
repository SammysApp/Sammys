//
//  FoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// View food details and edit if neccesarry.
class FoodViewController: UIViewController, Storyboardable {
    typealias ViewController = FoodViewController
    
    var food: Food!
    var didGoBack: ((FoodViewController) -> Void)?
    
    // MARK: - IBOutlets & View Properties
    var collectionView: FoodCollectionView!

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView = FoodCollectionView(frame: CGRect.zero, food: food)
//        collectionView.foodDelegate = self
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            didGoBack?(self)
        }
    }
    
    func updateUI() {
        navigationItem.title = food.title
    }
}

//extension FoodViewController: FoodCollectionViewDelegate {
//    func didTapEdit(for title: String) {
//        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
//        itemsViewController.salad = food as! Salad
//        itemsViewController.edit(for: title)
//        itemsViewController.isEditingFood = true
//        itemsViewController.didFinishEditing = {
//            self.collectionView.reloadData()
//            self.updateUI()
//        }
//        navigationController?.pushViewController(itemsViewController, animated: true)
//    }
//}

