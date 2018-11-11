//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum ItemsViewModelError: Error {
	case nonAdjustable
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
	typealias Section = CollectionViewSection<ItemCollectionViewCellViewModel>
	
	private let viewDelegate: ItemsViewModelViewDelegate
	private var parcel: ItemsViewModelParcel
	
	private(set) var itemCategory: Dynamic<FoodItemCategory>
	
	private var currentItemCategoryIndex: Int? {
		return parcel.itemCategories.firstIndex
			{ self.itemCategory.value.rawValue == $0.rawValue }
	}
	
	var isAtLastItemCategory: Bool {
		guard let currentIndex = currentItemCategoryIndex else { return false }
		return currentIndex == parcel.itemCategories.endIndex - 1
	}
	
	private var items = [Item]() {
		didSet { sections.value = sections(for: items) }
	}
	private(set) var sections = Dynamic([Section]())
	
	private(set) var centerCellViewModel: Dynamic<Section.CellViewModel?> = Dynamic(nil)
	
	var numberOfSections: Int { return sections.value.count }
	
	init(viewDelegate: ItemsViewModelViewDelegate, parcel: ItemsViewModelParcel) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
		
		guard let firstItemCategory = parcel.itemCategories.first
			else { fatalError() }
		self.itemCategory = Dynamic(firstItemCategory)
	}
	
	func setupData(for itemCategory: FoodItemCategory) -> Promise<Void> {
		return parcel.dataFetcher.getFoodItems(for: itemCategory)
			.get { self.items = $0 }.asVoid()
	}
	
	func set(to itemCategory: FoodItemCategory) {
		if parcel.itemCategories
			.map({ AnyEquatableProtocol($0) })
			.contains(AnyEquatableProtocol(itemCategory)) { self.itemCategory.value = itemCategory }
	}
	
	private func adjustItemCategory(byIndexValue indexValue: Int) throws {
		guard let currentIndex = currentItemCategoryIndex,
		let adjustedItemCategory = parcel.itemCategories[safe: currentIndex + indexValue]
			else { throw ItemsViewModelError.nonAdjustable }
		itemCategory.value = adjustedItemCategory
	}
	
	func incrementItemCategory() throws { try adjustItemCategory(byIndexValue: 1) }
	func decrementItemCategory() throws { try adjustItemCategory(byIndexValue: -1) }
	
	func sections(for items: [Item]) -> [Section] {
		return [CollectionViewSection(
			cellViewModels: items.map { ItemCollectionViewCellViewModelFactory(foodItem: $0, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() }
		)]
	}
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections.value[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel {
		return sections.value[indexPath.section].cellViewModels[indexPath.row]
	}
	
	func didCenterCellViewModel(at indexPath: IndexPath) {
		centerCellViewModel.value = sections.value[indexPath.section].cellViewModels[indexPath.item]
	}
	
	func toggle(_ foodItem: Item, with modifier: Modifier? = nil) throws {
		try parcel.builder.toggle(foodItem, with: modifier)
	}
	
	func addFoodViewModelParcel() throws -> AddFoodViewModelParcel {
		return AddFoodViewModelParcel(itemedPurchaseable: try parcel.builder.build())
	}
}
