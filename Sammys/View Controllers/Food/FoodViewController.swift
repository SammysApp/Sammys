//
//  FoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: FoodViewModelParcel!
	var viewModel: FoodViewModel!
	
	// MARK: - IBOutlets
	@IBOutlet var collectionView: UICollectionView!
	
	struct Constants {
		static let itemCollectionViewCellXibName = "ItemCollectionViewCell"
		
		static let collectionViewContentInset: CGFloat = 10
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = FoodViewModel(viewModelParcel, viewDelegate: self)
		
		setupCollectionView()
	}
	
	// MARK: - Setup
	func setupCollectionView() {
		collectionView.register(
			UINib(nibName: Constants.itemCollectionViewCellXibName, bundle: Bundle.main),
			forCellWithReuseIdentifier: FoodViewModel.ItemCellIdentifier.itemCell.rawValue
		)
		collectionView.contentInset.left = Constants.collectionViewContentInset
		collectionView.contentInset.right = Constants.collectionViewContentInset
	}
}

// MARK: - UICollectionViewDataSource
extension FoodViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return viewModel.numberOfSections
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.numberOfItems(inSection: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
		cellViewModel.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
		return cell
	}
}

extension FoodViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return viewModel.cellViewModel(for: indexPath).size
	}
}

// MARK: - Storyboardable
extension FoodViewController: Storyboardable {}

// MARK: - FoodViewModelViewDelegate
extension FoodViewController: FoodViewModelViewDelegate {
	func cellWidth() -> Double {
		let totalCellsWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return Double(totalCellsWidth) / 2 }
		return Double(totalCellsWidth - (layout.minimumInteritemSpacing * (2 - 1))) / 2
	}
	func cellHeight() -> Double { return cellWidth() }
}
