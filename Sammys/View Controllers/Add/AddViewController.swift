//
//  AddViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate {
    func addViewControllerDidComplete(_ addViewController: AddViewController)
    func addViewControllerDidCancel(_ addViewController: AddViewController)
}

/// View food details and add to bag.
class AddViewController: UIViewController, AddViewModelDelegate, Storyboardable {
    typealias ViewController = AddViewController
    
    var delegate: AddViewControllerDelegate?
    var viewModel: AddViewModel!
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var addButton: UIButton!
    
    var collectionView: FoodCollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
        static let cancelAlertTitle = "You sure?"
        static let cancelAlettMessage = "This will disregard your work."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        navigationController?.navigationBar.isTranslucent = false
        
        collectionView = FoodCollectionView(frame: CGRect.zero, viewModel: viewModel.collectionViewModel)
        
        view.insertSubview(collectionView, at: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        collectionView.contentInset.bottom = addButton.frame.height + 40
        
        addButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func presentCancelAlertController() {
        let checkoutAlertController = UIAlertController(title: Constants.cancelAlertTitle, message: Constants.cancelAlettMessage, preferredStyle: .alert)
        [UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true) { self.delegate?.addViewControllerDidCancel(self) }
        }),
         UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            checkoutAlertController.dismiss(animated: true, completion: nil)
         })].forEach { checkoutAlertController.addAction($0) }
        present(checkoutAlertController, animated: true, completion: nil)
    }
    
    func didTapEdit() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        presentCancelAlertController()
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.addFoodToBag()
        dismiss(animated: true) { self.delegate?.addViewControllerDidComplete(self) }
    }
    
    @IBAction func didTapFave(_ sender: UIButton) {
        viewModel.addFoodAsFave()
    }
}
