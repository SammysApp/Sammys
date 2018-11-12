//
//  BuilderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum BuilderViewModelError: Error {
	case nonAdjustable
}

struct BuilderViewModelParcel {
	let categories: [ItemCategory]
	let fetcher: ItemsFetcher.Type
	var builder: ItemedPurchaseableBuilder
}

protocol BuilderViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

class BuilderViewModel {
	typealias Section = CollectionViewSection<ItemCollectionViewCellViewModel>
	
	private let viewDelegate: BuilderViewModelViewDelegate
	private var parcel: BuilderViewModelParcel
	
	private(set) var itemCategory: Dynamic<ItemCategory>
	
	private var currentItemCategoryIndex: Int? {
		return parcel.categories.firstIndex
			{ self.itemCategory.value.rawValue == $0.rawValue }
	}
	
	var isAtLastItemCategory: Bool {
		guard let currentIndex = currentItemCategoryIndex else { return false }
		return currentIndex == parcel.categories.endIndex - 1
	}
	
	private var items = [Item]() {
		didSet { sections.value = sections(for: items) }
	}
	private(set) var sections = Dynamic([Section]())
	
	private(set) var centerCellViewModel: Dynamic<Section.CellViewModel?> = Dynamic(nil)
	
	var numberOfSections: Int { return sections.value.count }
	
	init(viewDelegate: BuilderViewModelViewDelegate, parcel: BuilderViewModelParcel) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
		
		guard let firstItemCategory = parcel.categories.first
			else { fatalError() }
		self.itemCategory = Dynamic(firstItemCategory)
	}
	
	func setupData(for itemCategory: ItemCategory) -> Promise<Void> {
		return parcel.fetcher.getItems(for: itemCategory)
			.get { self.items = $0 }.asVoid()
	}
	
	func set(to itemCategory: ItemCategory) {
		if parcel.categories
			.map({ AnyEquatableProtocol($0) })
			.contains(AnyEquatableProtocol(itemCategory)) { self.itemCategory.value = itemCategory }
	}
	
	private func adjustItemCategory(byIndexValue indexValue: Int) throws {
		guard let currentIndex = currentItemCategoryIndex,
		let adjustedItemCategory = parcel.categories[safe: currentIndex + indexValue]
			else { throw BuilderViewModelError.nonAdjustable }
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
	
	func addFoodViewModelParcel() throws -> AddBagViewModelParcel {
		return AddBagViewModelParcel(itemedPurchaseable: try parcel.builder.build())
	}
}
