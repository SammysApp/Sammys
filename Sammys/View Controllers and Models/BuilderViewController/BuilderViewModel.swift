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
//	let fetcher: ItemsFetcher
	let builder: ItemedPurchasableBuilder
	let userState: UserState
}

protocol BuilderViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

enum BuilderCellIdentifier: String {
	case itemCell
}

enum BuilderViewModelError: Error {
	case needsParcel, nonAdjustable
}

class BuilderViewModel {
	typealias Section = DefaultCollectionViewSection<ItemCollectionViewCellViewModel>
	
	var parcel: BuilderViewModelParcel?
	private let viewDelegate: BuilderViewModelViewDelegate
	
	private(set) lazy var currentItemCategory = { parcel?.categories.first }()
	private lazy var builder = { parcel?.builder }()
	lazy var userState = { parcel?.userState ?? .noUser }()
	
	// MARK: - Data
	private var sections = [Section]()
	private func sections(for items: [Item]) -> [Section] { return [
		Section(cellViewModels: items.map { ItemCollectionViewCellViewModelFactory(item: $0, identifier: BuilderCellIdentifier.itemCell.rawValue, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	private var currentItemCategoryIndex: Int? {
		return nil
//		return parcel?.categories.firstIndex
//			{ self.currentItemCategory?.isEqual(to: $0) ?? false }
	}
	
	var isAtLastItemCategory: Bool {
		guard let currentIndex = currentItemCategoryIndex,
			let endIndex = parcel?.categories.endIndex
			else { return false }
		return currentIndex == endIndex - 1
	}
	
	init(parcel: BuilderViewModelParcel?, viewDelegate: BuilderViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
	}
	
	func setupData(for itemCategory: ItemCategory) -> Promise<Void> {
		guard let parcel = parcel
			else { return Promise(error: BuilderViewModelError.needsParcel) }
		return Promise<Void>()
//		return parcel.fetcher.items(for: itemCategory)
//			.get { self.sections = self.sections(for: $0) }.asVoid()
	}
	
	func set(_ itemCategory: ItemCategory) {
		guard let parcel = parcel else { return }
//		if parcel.categories
//			.map({ AnyEquatableProtocol($0) })
//			.contains(AnyEquatableProtocol(itemCategory))
//		{ self.currentItemCategory = itemCategory }
	}
	
	private func adjustItemCategory(byIndexValue indexValue: Int) throws {
		guard let currentIndex = currentItemCategoryIndex,
		let adjustedItemCategory = parcel?.categories[safe: currentIndex + indexValue]
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
	
	func toggle(_ item: Item) throws {
//		try builder?.toggle(item)
	}
	
//	func build() throws -> ItemedPurchasable {
//		guard let builder = builder else { throw BuilderViewModelError.needsParcel }
//		return try builder.build()
//	}
}

extension BuilderViewModelParcel {
	static func instance(for itemedPurchasableType: ItemedPurchasable.Type, userState: UserState) -> BuilderViewModelParcel? {
		return nil
//		guard let itemsFetchableType = itemedPurchasableType as? ItemsFetchable.Type,
//			let itemedPurchasableBuildableType = itemedPurchasableType as? ItemedPurchasableBuildable.Type
//			else { return nil }
//		return BuilderViewModelParcel(
//			categories: itemedPurchasableType.allItemCategories,
//			fetcher: itemsFetchableType.fetcher,
//			builder: itemedPurchasableBuildableType.builder,
//			userState: userState
//		)
	}
	
	static func instance(for itemedPurchasable: ItemedPurchasable, userState: UserState) -> BuilderViewModelParcel? {
		return nil
//		let itemedPurchasableType = type(of: itemedPurchasable)
//		guard let itemsFetchableType = itemedPurchasableType as? ItemsFetchable.Type,
//			let itemedPurchasableBuildableType = itemedPurchasableType as? ItemedPurchasableBuildable.Type
//			else { return nil }
//		var builder = itemedPurchasableBuildableType.builder
//		do { try builder.toggleExisting(from: itemedPurchasable) } catch { return nil }
//		return BuilderViewModelParcel(
//			categories: itemedPurchasableType.allItemCategories,
//			fetcher: itemsFetchableType.fetcher,
//			builder: builder,
//			userState: userState
//		)
	}
}
