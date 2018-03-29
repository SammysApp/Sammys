//
//  AddViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// View food details and add to bag.
class AddViewController: UIViewController, AddViewModelDelegate, Storyboardable {
    typealias ViewController = AddViewController
    
    var viewModel: AddViewModel!
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var addButton: UIButton!
    
    var collectionView: FoodCollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        collectionView = FoodCollectionView(frame: CGRect.zero, viewModel: viewModel.collectionViewModel)
        
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
    
    func didTapEdit() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.addFoodToBag()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        viewModel.addFoodAsFave()
    }
}
