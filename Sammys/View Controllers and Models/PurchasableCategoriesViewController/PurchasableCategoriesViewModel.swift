//
//  PurchasableCategoriesViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoriesViewModelParcel {
	let categories: [PurchasableCategoryNode]
}

protocol PurchasableCategoriesViewModelViewDelegate {
	func cellHeight() -> Double
}

class PurchasableCategoriesViewModel {
	typealias Section = DefaultTableViewSection<PurchasableCategoriesTableViewCellViewModel>
	
	var parcel: PurchasableCategoriesViewModelParcel?
	private var viewDelegate: PurchasableCategoriesViewModelViewDelegate
	
	var sections: [Section] { return [
		
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: PurchasableCategoriesViewModelParcel?, viewDelegate: PurchasableCategoriesViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
}
