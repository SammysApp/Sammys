//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol BagViewModelViewDelegate {
	func cellHeight() -> Double
}

class BagViewModel {
	typealias Section = TableViewSection<BagPurchaseableTableViewCellViewModel>
	
	private let viewDelegate: BagViewModelViewDelegate
	
	private let bagModelController = BagModelController()
	private var purchaseables: [Purchaseable] {
		do { return try bagModelController.getPurchasableQuantities().map { $0.purchaseable } }
		catch { print(error); return [] }
	}
	private var sections: [Section] {
		return [
			Section(cellViewModels: purchaseables
				.map { BagPurchaseableTableViewCellViewModelFactory(purchaseable: $0, height: viewDelegate.cellHeight()).create() }
			)
		]
	}
	
	var numberOfSections: Int { return sections.count }
	
	init(_ viewDelegate: BagViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel {
		return sections[indexPath.section].cellViewModels[indexPath.row]
	}
	
	func delete(at indexPath: IndexPath) throws {
		try bagModelController.remove(cellViewModel(for: indexPath).purchaseable)
	}
}
