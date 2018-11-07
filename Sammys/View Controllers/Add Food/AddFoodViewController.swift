//
//  AddFoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class AddFoodViewController: UIViewController {
	var viewModelParcel: AddFoodViewModelParcel!
	var viewModel: AddFoodViewModel!
	
	lazy var foodViewController: FoodViewController = {
		let foodViewController = FoodViewController.storyboardInstance()
		foodViewController.viewModelParcel = viewModel.foodViewModelParcel
		return foodViewController
	}()

    // MARK: - IBOutlets
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel = AddFoodViewModel(viewModelParcel)
		
		add(asChildViewController: foodViewController)
		foodViewController.view.translatesAutoresizingMaskIntoConstraints = false
		foodViewController.view.fullViewConstraints(equalTo: view).activateAll()
    }
}

// MARK: - Storyboardable
extension AddFoodViewController: Storyboardable {}
