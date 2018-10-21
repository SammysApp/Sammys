//
//  FoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// View food details and edit if neccesarry.
class FoodViewController: UIViewController, FoodViewModelDelegate, Storyboardable {
//    typealias ViewController = FoodViewController
//    
//    var viewModel: FoodViewModel!
//    
//    var didGoBack: ((FoodViewController) -> Void)?
//    
//    // MARK: - IBOutlets & View Properties
//    var collectionView: FoodCollectionView!
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        viewModel.delegate = self
//        
//        navigationController?.navigationBar.isTranslucent = false
//        
//        collectionView = FoodCollectionView(frame: CGRect.zero, viewModel: viewModel.collectionViewModel)
//        
//        view.insertSubview(collectionView, at: 0)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
//        ])
//        
//        updateUI()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if isMovingFromParentViewController {
//            didGoBack?(self)
//        }
//    }
//    
//    func updateUI() {
//        navigationItem.title = viewModel.navigationItemTitle
//    }
//    
//    func didTapEdit(for itemType: ItemType) {
//        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
//        itemsViewController.resetFood(to: viewModel.food)
//        itemsViewController.edit(for: itemType)
//        itemsViewController.isEditingFood = true
//        itemsViewController.didFinishEditing = {
//            self.collectionView.reloadData()
//            self.updateUI()
//        }
//        navigationController?.pushViewController(itemsViewController, animated: true)
//    }
}
