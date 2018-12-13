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
	let itemsPromises: [ItemCategory: Promise<[Item]>]
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
	
	private var categories: [ItemCategory] { return parcel?.categories ?? [] }
	private(set) lazy var currentCategory = { categories.first }()
	private lazy var builder = { parcel?.builder }()
	lazy var userState = { parcel?.userState ?? .noUser }()
	
	private var sections = [Section]()
	private func sections(for items: [Item]) -> [Section] { return [
		Section(cellViewModels: items.map { ItemCollectionViewCellViewModelFactory(item: $0, identifier: BuilderCellIdentifier.itemCell.rawValue, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	private var currentCategoryIndex: Int? {
		guard let currentCategory = currentCategory else { return nil }
		return categories.firstIndex(of: currentCategory)
	}
	
	var isAtLastItemCategory: Bool {
		guard let currentIndex = currentCategoryIndex else { return false }
		return currentIndex == categories.endIndex - 1
	}
	
	init(parcel: BuilderViewModelParcel?, viewDelegate: BuilderViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
	}
	
	func setupData(for itemCategory: ItemCategory) -> Promise<Void> {
		guard let itemsPromise = parcel?.itemsPromises[itemCategory]
			else { return Promise(error: BuilderViewModelError.needsParcel) }
		return itemsPromise.get { self.sections = self.sections(for: $0) }.asVoid()
	}
	
	func set(_ itemCategory: ItemCategory) { }
	
	private func adjustItemCategory(byIndexValue indexValue: Int) throws {
		guard let currentIndex = currentCategoryIndex,
			let adjustedItemCategory = categories[safe: currentIndex + indexValue]
			else { throw BuilderViewModelError.nonAdjustable }
		currentCategory = adjustedItemCategory
	}
	
	func incrementItemCategory() throws { try adjustItemCategory(byIndexValue: 1) }
	func decrementItemCategory() throws { try adjustItemCategory(byIndexValue: -1) }
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
	
	func toggle(_ item: Item) throws { }
}

extension BuilderViewModelParcel {
	static func instance(for itemedPurchasableType: ItemedPurchasable.Type, userState: UserState) -> BuilderViewModelParcel? {
		return nil
	}
	
	static func instance(for itemedPurchasable: ItemedPurchasable, userState: UserState) -> BuilderViewModelParcel? {
		return nil
	}
}
