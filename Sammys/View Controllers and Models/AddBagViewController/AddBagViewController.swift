//
//  AddBagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol AddBagViewControllerDelegate: ItemsViewControllerDelegate {
	func addBagViewController(_ addBagViewController: AddBagViewController, didAddItemedPurchasable itemedPurchasable: ItemedPurchasable)
	func addBagViewControllerDidCancel(_ addBagViewController: AddBagViewController)
}

class AddBagViewController: UIViewController {
	var viewModelParcel: AddBagViewModelParcel!
	var viewModel: AddBagViewModel!
	
	var delegate: AddBagViewControllerDelegate?
	
	lazy var itemsViewController: ItemsViewController = {
		let itemsViewController = ItemsViewController.storyboardInstance()
		itemsViewController.viewModelParcel = viewModel.itemsViewModelParcel
		itemsViewController.delegate = delegate
		return itemsViewController
	}()

    // MARK: - IBOutlets
	@IBOutlet var addButton: UIButton!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let addButtonCornerRadius: CGFloat = 20
	}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel = AddBagViewModel(viewModelParcel)
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupChildItemsViewController()
		setupAddButton()
	}
	
	func setupChildItemsViewController() {
		add(asChildViewController: itemsViewController)
		itemsViewController.view.translatesAutoresizingMaskIntoConstraints = false
		itemsViewController.view.fullViewConstraints(equalTo: view).activateAll()
		view.sendSubview(toBack: itemsViewController.view)
	}
	
	func setupAddButton() {
		addButton.layer.cornerRadius = Constants.addButtonCornerRadius
	}
	
	// MARK: - IBActions
	@IBAction func didTapAdd(_ sender: UIButton) {
		do { try viewModel.add() } catch { print(error) }
		delegate?.addBagViewController(self, didAddItemedPurchasable: viewModel.itemedPurchasable)
	}
}

// MARK: - Storyboardable
extension AddBagViewController: Storyboardable {}

extension AddBagViewControllerDelegate {
	// Make function requirement optional.
	func addBagViewControllerDidCancel(_ addBagViewController: AddBagViewController) {}
}
