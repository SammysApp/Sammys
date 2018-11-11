//
//  FoodViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol FoodViewControllerDelegate {
	func foodViewController(_ foodViewController: FoodViewController, didSelectEdit itemCategory: FoodItemCategory, in itemedPurchaseable: ItemedPurchaseable)
}

class FoodViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: FoodViewModelParcel!
	var viewModel: FoodViewModel!
	
	var delegate: FoodViewControllerDelegate?
	
	private var supplementaryViewIndexPaths = [UICollectionReusableView : IndexPath]()
	
	// MARK: - IBOutlets
	@IBOutlet var collectionView: UICollectionView!
	
	struct Constants {
		static let foodCollectionViewSectionHeaderViewReuseIdentifier = "foodCollectionViewSectionHeaderView"
		
		static let collectionViewContentInset: CGFloat = 10
		static let collectionViewNumberOfItemsPerRow = 2
		static let collectionViewHeaderHeight: CGFloat = 80
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = FoodViewModel(viewModelParcel, viewDelegate: self)
		
		setupViews()
	}
	
	// MARK: - Setup
	func setupViews() {
		setupCollectionView()
	}
	
	func setupCollectionView() {
		collectionView.register(ItemCollectionViewCell.nib(), forCellWithReuseIdentifier: FoodViewModel.ItemCellIdentifier.itemCell.rawValue)
		collectionView.register(FoodCollectionViewSectionHeaderView.nib(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.foodCollectionViewSectionHeaderViewReuseIdentifier)
		collectionView.contentInset.left = Constants.collectionViewContentInset
		collectionView.contentInset.right = Constants.collectionViewContentInset
		(collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: collectionView.frame.width, height: Constants.collectionViewHeaderHeight)
	}
}

// MARK: - Storyboardable
extension FoodViewController: Storyboardable {}

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
		cellViewModel.commands[.configuration]?.perform(parameters: CollectionViewCellCommandParameters(cell: cell))
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		switch kind {
		case UICollectionElementKindSectionHeader:
			guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.foodCollectionViewSectionHeaderViewReuseIdentifier, for: indexPath) as? FoodCollectionViewSectionHeaderView else { break }
			sectionHeader.delegate = self
			sectionHeader.titleLabel.text = viewModel.itemCategory(forSection: indexPath.section).name
			view = sectionHeader
		default: break
		}
		supplementaryViewIndexPaths[view] = indexPath
		return view
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) { supplementaryViewIndexPaths[view] = nil }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FoodViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
	}
}

// MARK: - FoodViewModelViewDelegate
extension FoodViewController: FoodViewModelViewDelegate {
	func cellWidth() -> Double {
		let totalCellsWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return Double(totalCellsWidth) / Double(Constants.collectionViewNumberOfItemsPerRow) }
		return Double(totalCellsWidth - (layout.minimumInteritemSpacing * CGFloat(Constants.collectionViewNumberOfItemsPerRow - 1))) / Double(Constants.collectionViewNumberOfItemsPerRow)
	}
	func cellHeight() -> Double { return cellWidth() }
}

// MARK: - FoodCollectionViewSectionHeaderViewDelegate
extension FoodViewController: FoodCollectionViewSectionHeaderViewDelegate {
	func foodCollectionViewSectionHeaderView(_ foodCollectionViewSectionHeaderView: FoodCollectionViewSectionHeaderView, didTapEdit editButton: UIButton) {
		guard let section = supplementaryViewIndexPaths[foodCollectionViewSectionHeaderView]?.section else { return }
		let itemCategory = viewModel.itemCategory(forSection: section)
		delegate?.foodViewController(self, didSelectEdit: itemCategory, in: viewModel.itemedPurchaseable)
	}
}
