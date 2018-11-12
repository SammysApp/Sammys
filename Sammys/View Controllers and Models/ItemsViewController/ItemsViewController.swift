//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol ItemsViewControllerDelegate {
	func itemsViewController(_ itemsViewController: ItemsViewController, didSelectEdit itemCategory: ItemCategory, in itemedPurchaseable: ItemedPurchaseable)
}

class ItemsViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: ItemsViewModelParcel!
	var viewModel: ItemsViewModel!
	
	var delegate: ItemsViewControllerDelegate?
	
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
		
		viewModel = ItemsViewModel(viewModelParcel, viewDelegate: self)
		
		setupViews()
	}
	
	// MARK: - Setup
	func setupViews() {
		setupCollectionView()
	}
	
	func setupCollectionView() {
		collectionView.register(ItemCollectionViewCell.nib(), forCellWithReuseIdentifier: ItemsViewModel.ItemCellIdentifier.itemCell.rawValue)
		collectionView.register(ItemsCollectionViewSectionHeaderView.nib(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.foodCollectionViewSectionHeaderViewReuseIdentifier)
		collectionView.contentInset.left = Constants.collectionViewContentInset
		collectionView.contentInset.right = Constants.collectionViewContentInset
		(collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: collectionView.frame.width, height: Constants.collectionViewHeaderHeight)
	}
}

// MARK: - Storyboardable
extension ItemsViewController: Storyboardable {}

// MARK: - UICollectionViewDataSource
extension ItemsViewController: UICollectionViewDataSource {
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
			guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.foodCollectionViewSectionHeaderViewReuseIdentifier, for: indexPath) as? ItemsCollectionViewSectionHeaderView else { break }
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
extension ItemsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
	}
}

// MARK: - ItemsViewModelViewDelegate
extension ItemsViewController: ItemsViewModelViewDelegate {
	func cellWidth() -> Double {
		let totalCellsWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return Double(totalCellsWidth) / Double(Constants.collectionViewNumberOfItemsPerRow) }
		return Double(totalCellsWidth - (layout.minimumInteritemSpacing * CGFloat(Constants.collectionViewNumberOfItemsPerRow - 1))) / Double(Constants.collectionViewNumberOfItemsPerRow)
	}
	func cellHeight() -> Double { return cellWidth() }
}

// MARK: - ItemsCollectionViewSectionHeaderViewDelegate
extension ItemsViewController: ItemsCollectionViewSectionHeaderViewDelegate {
	func itemsCollectionViewSectionHeaderView(_ itemsCollectionViewSectionHeaderView: ItemsCollectionViewSectionHeaderView, didTapEdit editButton: UIButton) {
		guard let section = supplementaryViewIndexPaths[itemsCollectionViewSectionHeaderView]?.section else { return }
		let itemCategory = viewModel.itemCategory(forSection: section)
		delegate?.itemsViewController(self, didSelectEdit: itemCategory, in: viewModel.itemedPurchaseable)
	}
}
