//
//  AddViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// View food details and add to bag.
class AddViewController: UIViewController, Storyboardable {
    typealias ViewController = AddViewController
    
    var food: Food!
    
    var editDelegate: Editable?
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var addButton: UIButton!
    
    var collectionView: FoodCollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = FoodCollectionView(frame: CGRect.zero, food: food)
        collectionView.foodDelegate = self
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        addButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        BagDataStore.shared.add(food)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        UserAPIClient.set(food as! Salad, for: UserDataStore.shared.user!)
    }
}

extension AddViewController: FoodCollectionViewDelegate {
    func didTapEdit(for title: String) {
        editDelegate?.edit(for: title)
        navigationController?.popViewController(animated: true)
    }
}
