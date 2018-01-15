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
    
    // MARK: IBOutlets & View Properties
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var dataSource = FoodCollectionViewDataSource(food: food)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor(named: "Snow")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.alwaysBounceVertical = true
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        addButton.layer.cornerRadius = 20
    }
    
    @IBAction func addToBag(_ sender: UIButton) {
        BagDataStore.shared.add(food)
    }
    
    @IBAction func fave(_ sender: UIButton) {
        UserDataStore.shared.user?.favorites.append(food as! Salad)
    }
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
