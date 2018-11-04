//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum ItemsViewModelError: Error {
	case nonIncrementable
}

struct ItemsViewModelParcel {
	let itemCategories: [FoodItemCategory]
	let dataFetcher: FoodItemsDataFetcher.Type
	var builder: FoodBuilder
}

protocol ItemsViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

class ItemsViewModel {
	typealias ItemsCollectionViewSection = CollectionViewSection<ItemCollectionViewCellViewModel>
	
	private let viewDelegate: ItemsViewModelViewDelegate
	private var parcel: ItemsViewModelParcel
	
	private(set) var itemCategory: Dynamic<FoodItemCategory>
	private var currentItemCategoryIndex: Int? {
		return parcel.itemCategories.firstIndex
			{ self.itemCategory.value.stringValue == $0.stringValue }
	}
	
	private var items = [FoodItem]() {
		didSet { sections.value = sections(for: items) }
	}
	private(set) var sections = Dynamic([ItemsCollectionViewSection]())
	
	private(set) var centerCellViewModel: Dynamic<ItemCollectionViewCellViewModel?> = Dynamic(nil)
	
	var numberOfSections: Int { return sections.value.count }
	
	init(viewDelegate: ItemsViewModelViewDelegate, parcel: ItemsViewModelParcel) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
		
		guard let firstItemCategory = parcel.itemCategories.first
			else { fatalError() }
		self.itemCategory = Dynamic(firstItemCategory)
		
		parcel.dataFetcher.getFoodItems(for: firstItemCategory)
			.get { self.items = $0 }.catch { print($0) }
	}
	
	func incrementItemCategory() throws {
		guard let currentIndex = currentItemCategoryIndex,
		let nextItemCategory = parcel.itemCategories[safe: currentIndex + 1]
			else { throw ItemsViewModelError.nonIncrementable }
		itemCategory.value = nextItemCategory
		
		parcel.dataFetcher.getFoodItems(for: itemCategory.value)
			.get { self.items = $0 }.catch { print($0) }
	}
	
	func sections(for items: [FoodItem]) -> [ItemsCollectionViewSection] {
		return [CollectionViewSection(
			cellViewModels: items.map { ItemCollectionViewCellViewModelFactory(foodItem: $0, size: cellSize()).create() }
		)]
	}
	
	func cellSize() -> CGSize {
		return CGSize(width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight())
	}
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections.value[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> CollectionViewCellViewModel {
		return sections.value[indexPath.section].cellViewModels[indexPath.row]
	}
	
	func didCenterCellViewModel(at indexPath: IndexPath) {
		centerCellViewModel.value = sections.value[indexPath.section].cellViewModels[indexPath.item]
	}
}
