//
//  FoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController, Storyboardable {
    typealias ViewController = FoodViewController
    
    var navigationItemTitle: String?
    var food: Food!
    var didGoBack: ((FoodViewController) -> Void)?
    
    // MARK: IBOutlets & View Properties
    
    var collectionView: FoodCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle

        collectionView = FoodCollectionView(frame: CGRect.zero, food: food)
        collectionView.foodDelegate = self
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
}

extension FoodViewController: FoodCollectionViewDelegate {
    func didTapEdit(for title: String) {
        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
        itemsViewController.salad = food as! Salad
        itemsViewController.edit(for: title)
        itemsViewController.isEditingFood = true
        itemsViewController.finishEditing = {
            self.collectionView.reloadData()
        }
        navigationController?.pushViewController(itemsViewController, animated: true)
    }
}
