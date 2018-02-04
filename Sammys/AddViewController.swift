//
//  AddViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, Storyboardable {
    typealias ViewController = AddViewController
    
    var food: Food!
    var delegate: Editable?
    
    // MARK: IBOutlets & View Properties
    @IBOutlet var addButton: UIButton!
    
    var collectionView: FoodCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = FoodCollectionView(frame: CGRect.zero, food: food)
        collectionView.foodDelegate = self
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        addButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addToBag(_ sender: UIButton) {
        BagDataStore.shared.add(food)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func fave(_ sender: UIButton) {
        UserAPIClient.set(food as! Salad, for: UserDataStore.shared.user!)
    }
}

extension AddViewController: FoodCollectionViewDelegate {
    func didTapEdit(for title: String) {
        delegate?.edit(for: title)
        navigationController?.popViewController(animated: true)
    }
}
