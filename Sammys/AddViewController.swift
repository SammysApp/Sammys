//
//  AddViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol AddDelegate {
    func edit(for title: String)
}

class AddViewController: UIViewController, Storyboardable {
    typealias ViewController = AddViewController
    
    var food: Food!
    var delegate: AddDelegate?
    
    // MARK: IBOutlets & View Properties
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    var collectionView: FoodCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        collectionView = FoodCollectionView(frame: CGRect.zero, food: food)
        collectionView.foodDelegate = self
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        addButton.layer.cornerRadius = 20
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addToBag(_ sender: UIButton) {
        BagDataStore.shared.add(food)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func fave(_ sender: UIButton) {
        UserDataStore.shared.user?.favorites.append(food as! Salad)
    }
}

extension AddViewController: FoodCollectionViewDelegate {
    func didTapEdit(for title: String) {
        delegate?.edit(for: title)
        navigationController?.popViewController(animated: true)
    }
}
