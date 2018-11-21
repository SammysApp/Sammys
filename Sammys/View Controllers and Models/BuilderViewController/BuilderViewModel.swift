//
//  BuilderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct BuilderViewModelParcel {
	let categories: [ItemCategory]
	let fetcher: ItemsFetcher
	var builder: ItemedPurchasableBuilder
}

protocol BuilderViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

enum BuilderCellIdentifier: String {
	case itemCell
}

enum BuilderViewModelError: Error {
	case nonAdjustable
}

class BuilderViewModel {
	typealias Section = CollectionViewSection<ItemCollectionViewCellViewModel>
	
	private var parcel: BuilderViewModelParcel
	private let viewDelegate: BuilderViewModelViewDelegate
	
	private(set) var currentItemCategory: ItemCategory
	
	// MARK: - Data
	private var sections = [Section]()
	private func sections(for items: [Item]) -> [Section] { return [
		CollectionViewSection(cellViewModels: items.map { ItemCollectionViewCellViewModelFactory(item: $0, identifier: BuilderCellIdentifier.itemCell.rawValue, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	private var currentItemCategoryIndex: Int? {
		return parcel.categories.firstIndex
			{ self.currentItemCategory.isEqual(to: $0) }
	}
	
	var isAtLastItemCategory: Bool {
		guard let currentIndex = currentItemCategoryIndex else { return false }
		return currentIndex == parcel.categories.endIndex - 1
	}
	
	init(parcel: BuilderViewModelParcel, viewDelegate: BuilderViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
		
		guard let firstItemCategory = parcel.categories.first
			else { fatalError("Need item categories to build") }
		currentItemCategory = firstItemCategory
	}
	
	func setupData(for itemCategory: ItemCategory) -> Promise<Void> {
		return parcel.fetcher.items(for: itemCategory)
			.get { self.sections = self.sections(for: $0) }.asVoid()
	}
	
	func set(_ itemCategory: ItemCategory) {
		if parcel.categories
			.map({ AnyEquatableProtocol($0) })
			.contains(AnyEquatableProtocol(itemCategory))
		{ self.currentItemCategory = itemCategory }
	}
	
	private func adjustItemCategory(byIndexValue indexValue: Int) throws {
		guard let currentIndex = currentItemCategoryIndex,
		let adjustedItemCategory = parcel.categories[safe: currentIndex + indexValue]
			else { throw BuilderViewModelError.nonAdjustable }
		currentItemCategory = adjustedItemCategory
	}
	
	func incrementItemCategory() throws { try adjustItemCategory(byIndexValue: 1) }
	func decrementItemCategory() throws { try adjustItemCategory(byIndexValue: -1) }
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
	
	func toggle(_ item: Item) throws { try parcel.builder.toggle(item) }
	
	func build() throws -> ItemedPurchasable { return try parcel.builder.build() }
}

extension BuilderViewModelParcel {
	static func instance(for itemedPurchasableType: ItemedPurchasable.Type) -> BuilderViewModelParcel? {
		guard let itemsFetchableType = itemedPurchasableType as? ItemsFetchable.Type,
			let itemedPurchasableBuildableType = itemedPurchasableType as? ItemedPurchasableBuildable.Type
			else { return nil }
		return BuilderViewModelParcel(
			categories: itemedPurchasableType.allItemCategories,
			fetcher: itemsFetchableType.fetcher,
			builder: itemedPurchasableBuildableType.builder
		)
	}
}
