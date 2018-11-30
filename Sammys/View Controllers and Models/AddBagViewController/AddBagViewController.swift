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
	var viewModelParcel: AddBagViewModelParcel?
		{ didSet { viewModel.parcel = viewModelParcel } }
	lazy var viewModel = AddBagViewModel(viewModelParcel)
	
	var delegate: AddBagViewControllerDelegate?
	
	// MARK: - View Controllers
	lazy var itemsViewController = { ItemsViewController.storyboardInstance().settingDelegate(to: delegate) }()

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
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupChildItemsViewController()
		setupAddButton()
		loadViews()
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
	
	// MARK: - Load
	func loadViews() {
		if let itemedPurchasable = viewModel.itemedPurchasable { itemsViewController.viewModelParcel = ItemsViewModelParcel(itemedPurchasable: itemedPurchasable) }
	}
	
	// MARK: - IBActions
	@IBAction func didTapAdd(_ sender: UIButton) {
		do { try viewModel.add() } catch { print(error) }
		if let itemedPurchasable = viewModel.itemedPurchasable { delegate?.addBagViewController(self, didAddItemedPurchasable: itemedPurchasable) }
	}
}

// MARK: - Delegatable
extension AddBagViewController: Delegatable {}

// MARK: - Storyboardable
extension AddBagViewController: Storyboardable {}
