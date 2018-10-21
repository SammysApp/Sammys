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
class AddViewController: UIViewController/*, AddViewModelDelegate, Storyboardable*/ {
//    typealias ViewController = AddViewController
//
//    var delegate: AddViewControllerDelegate?
//    var viewModel: AddViewModel!
//
//    // MARK: - IBOutlets & View Properties
//    @IBOutlet var addButton: UIButton!
//    @IBOutlet var faveButton: UIBarButtonItem!
//
//    var collectionView: FoodCollectionView!
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    struct Constants {
//        static let cancelAlertTitle = "You sure?"
//        static let cancelAlettMessage = "This will disregard your work."
//    }
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        viewModel.delegate = self
//
//        navigationController?.navigationBar.isTranslucent = false
//        if navigationController?.viewControllers[0] != self {
//            navigationItem.leftBarButtonItems = nil
//        }
//
//        updateUI()
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
//        collectionView.contentInset.bottom = addButton.frame.height + 40
//
//        addButton.layer.cornerRadius = 20
//        updateFaveButton()
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
//            viewModel.handleMovingFromParentViewController(self)
//        }
//    }
//
//    func updateUI() {
//        title = viewModel.title
//    }
//
//    func updateFaveButton() {
//        faveButton.image = viewModel.faveButtonImage
//    }
//
//    func presentCancelAlertController() {
//        let checkoutAlertController = UIAlertController(title: Constants.cancelAlertTitle, message: Constants.cancelAlettMessage, preferredStyle: .alert)
//        [UIAlertAction(title: "OK", style: .default, handler: { action in
//            self.dismiss(animated: true) { self.delegate?.addViewControllerDidCancel(self) }
//        }),
//         UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//            checkoutAlertController.dismiss(animated: true, completion: nil)
//         })].forEach { checkoutAlertController.addAction($0) }
//        present(checkoutAlertController, animated: true, completion: nil)
//    }
//
//    func didUpdateFave() {
//        updateFaveButton()
//    }
//
//    func didTapEdit() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
//
//    func edit(for itemType: ItemType, with food: Food) {
//        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
//        itemsViewController.resetFood(to: food)
//        itemsViewController.edit(for: itemType)
//        itemsViewController.isEditingFood = true
//        itemsViewController.didFinishEditing = {
//            self.collectionView.reloadData()
//            self.updateUI()
//        }
//        navigationController?.pushViewController(itemsViewController, animated: true)
//    }
//
//    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
//        presentCancelAlertController()
//    }
//
//    @IBAction func didTapFave(_ sender: UIBarButtonItem) {
//        viewModel.handleDidTapFave()
//    }
//
//    @IBAction func didTapAdd(_ sender: UIButton) {
//        viewModel.addFoodToBag()
//        dismiss(animated: true) { self.delegate?.addViewControllerDidComplete(self) }
//    }
}
