//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

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
	private let viewDelegate: ItemsViewModelViewDelegate
	private var parcel: ItemsViewModelParcel
	
	private var items = [FoodItem]() {
		didSet { sections.value = sections(for: items) }
	}
	private(set) var sections = Dynamic([CollectionViewSection]())
	
	var numberOfSections: Int { return sections.value.count }
	
	init(viewDelegate: ItemsViewModelViewDelegate, parcel: ItemsViewModelParcel) {
		self.viewDelegate = viewDelegate
		self.parcel = parcel
		
		if let firstItemCategory = parcel.itemCategories.first {
			parcel.dataFetcher.getFoodItems(for: firstItemCategory)
				.get { self.items = $0 }.catch { print($0) }
		}
	}
	
	func sections(for items: [FoodItem]) -> [CollectionViewSection] {
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
}
