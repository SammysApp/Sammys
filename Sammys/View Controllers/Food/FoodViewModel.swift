//
//  FoodViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct FoodViewModelParcel {
	var food: Food
}

protocol FoodViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

class FoodViewModel {
	typealias Section = CollectionViewSection<DefaultCollectionViewCellViewModel>
	
	private let parcel: FoodViewModelParcel
	private let viewDelegate: FoodViewModelViewDelegate
	
	var sections: [Section] {
		return parcel.food.categorizedItems
			.map { Section(title: $0.category.name, cellViewModels: $0.items
				.map { ItemCollectionViewCellViewModelFactory(foodItem: $0, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() }) }
	}
	
	var numberOfSections: Int { return sections.count }
	
	init(_ parcel: FoodViewModelParcel, viewDelegate: FoodViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func numberOfItems(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel {
		return sections[indexPath.section].cellViewModels[indexPath.item]
	}
}
