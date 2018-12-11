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

enum PurchasableCategoriesCellIdentifier: String {
	case categoryCell
}

class PurchasableCategoriesViewModel {
	typealias Section = DefaultTableViewSection<PurchasableCategoryTableViewCellViewModel>
	
	var parcel: PurchasableCategoriesViewModelParcel?
	private var viewDelegate: PurchasableCategoriesViewModelViewDelegate
	
	var categories: [PurchasableCategoryNode] { return parcel?.categories ?? [] }
	var sections: [Section] { return [
		Section(cellViewModels: categories
			.map { PurchasableCategoryTableViewCellViewModelFactory(
					category: $0,
					identifier: PurchasableCategoriesCellIdentifier.categoryCell.rawValue,
					height: viewDelegate.cellHeight()
				).create() }
		)
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
