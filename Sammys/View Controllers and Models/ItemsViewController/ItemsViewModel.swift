//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ItemsViewModelParcel {
	var itemedPurchasable: ItemedPurchasable
}

protocol ItemsViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

enum ItemsCellIdentifier: String {
	case itemCell
}

class ItemsViewModel {
	typealias Section = CollectionViewSection<DefaultCollectionViewCellViewModel>
	
	private let parcel: ItemsViewModelParcel
	private let viewDelegate: ItemsViewModelViewDelegate
	
	// MARK: - Data
	var categorizedItems: [CategorizedItems] { return parcel.itemedPurchasable.categorizedItems }
	var sections: [Section] {
		return categorizedItems
			.map { Section(title: $0.category.name, cellViewModels: $0.items
				.map { ItemCollectionViewCellViewModelFactory(item: $0, identifier: ItemsCellIdentifier.itemCell.rawValue, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() }) }
	}
	
	var numberOfSections: Int { return sections.count }
	
	var itemedPurchasable: ItemedPurchasable { return parcel.itemedPurchasable }
	
	init(parcel: ItemsViewModelParcel, viewDelegate: ItemsViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.item]
	}
	
	func itemCategory(forSection section: Int) -> ItemCategory {
		return categorizedItems[section].category
	}
}
