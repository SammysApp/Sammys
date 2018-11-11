//
//  AddFoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol AddFoodViewControllerDelegate: FoodViewControllerDelegate {
	func addFoodViewController(_ addFoodViewController: AddFoodViewController, didAddItemedPurchaseable itemedPurchaseable: ItemedPurchaseable)
	func addFoodViewControllerDidCancel(_ addFoodViewController: AddFoodViewController)
}

class AddFoodViewController: UIViewController {
	var viewModelParcel: AddFoodViewModelParcel!
	var viewModel: AddFoodViewModel!
	
	var delegate: AddFoodViewControllerDelegate?
	
	lazy var foodViewController: FoodViewController = {
		let foodViewController = FoodViewController.storyboardInstance()
		foodViewController.viewModelParcel = viewModel.foodViewModelParcel
		foodViewController.delegate = delegate
		return foodViewController
	}()

    // MARK: - IBOutlets
	@IBOutlet var addButton: UIButton!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	struct Constants {
		static let addButtonCornerRadius: CGFloat = 20
	}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel = AddFoodViewModel(viewModelParcel)
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupChildFoodViewController()
		setupAddButton()
	}
	
	func setupChildFoodViewController() {
		add(asChildViewController: foodViewController)
		foodViewController.view.translatesAutoresizingMaskIntoConstraints = false
		foodViewController.view.fullViewConstraints(equalTo: view).activateAll()
		view.sendSubview(toBack: foodViewController.view)
	}
	
	func setupAddButton() {
		addButton.layer.cornerRadius = Constants.addButtonCornerRadius
	}
	
	// MARK: - IBActions
	@IBAction func didTapAdd(_ sender: UIButton) {
		do { try viewModel.add() } catch { print(error) }
		delegate?.addFoodViewController(self, didAddItemedPurchaseable: viewModel.itemedPurchaseable)
	}
}

// MARK: - Storyboardable
extension AddFoodViewController: Storyboardable {}

extension AddFoodViewControllerDelegate {
	// Make function requirement optional.
	func addFoodViewControllerDidCancel(_ addFoodViewController: AddFoodViewController) {}
}
