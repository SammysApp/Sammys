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
	var bagPurchaseableTableViewCellDelegate: BagPurchaseableTableViewCellDelegate?
	
	private let bagModelController = BagModelController()
	private var purchaseableQuantities: [PurchaseableQuantity] {
		do { return try bagModelController.getPurchasableQuantities() }
		catch { print(error); return [] }
	}
	
	private var sections: [Section] {
		return [
			Section(cellViewModels: purchaseableQuantities
				.map { BagPurchaseableTableViewCellViewModelFactory(purchaseableQuantity: $0, height: viewDelegate.cellHeight(), delegate: bagPurchaseableTableViewCellDelegate).create() }
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
	
	func increment(at indexPath: IndexPath) throws {
		try bagModelController.add(cellViewModel(for: indexPath).purchaseableQuantity.purchaseable)
	}
	
	func decrement(at indexPath: IndexPath) throws {
		try bagModelController.remove(cellViewModel(for: indexPath).purchaseableQuantity.purchaseable, quantity: 1)
	}
	
	func delete(at indexPath: IndexPath) throws {
		try bagModelController.remove(cellViewModel(for: indexPath).purchaseableQuantity.purchaseable)
	}
	
	func clear() { bagModelController.clearAll() }
}
