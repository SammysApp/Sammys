//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagViewModelError: Error {
	case badCellViewModelIndexPath
}

protocol BagViewModelViewDelegate {
	func cellHeight() -> Double
}

class BagViewModel {
	typealias Section = TableViewSection<BagPurchasableTableViewCellViewModel>
	
	private let viewDelegate: BagViewModelViewDelegate
	var bagPurchasableTableViewCellDelegate: BagPurchasableTableViewCellDelegate?
	
	private let bagModelController = BagModelController()
	private var purchasableQuantities: [PurchasableQuantity] {
		do { return try bagModelController.getPurchasableQuantities() }
		catch { print(error); return [] }
	}
	
	private var sections: [Section] {
		return [
			Section(cellViewModels: purchasableQuantities
				.map { BagPurchasableTableViewCellViewModelFactory(purchasableQuantity: $0, height: viewDelegate.cellHeight(), delegate: bagPurchasableTableViewCellDelegate).create() }
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
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
	
	func set(toQuantity quantity: Int, at indexPath: IndexPath) throws {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		try bagModelController.set(purchasable, toQuantity: quantity)
	}
	
	func updatePurchasable(at indexPath: IndexPath, to newPurchasable: Purchasable) throws {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		try bagModelController.update(purchasable, to: newPurchasable)
	}
	
	func incrementQuantity(at indexPath: IndexPath) throws {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		try bagModelController.add(purchasable)
	}
	
	func decrementQuantity(at indexPath: IndexPath) throws {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		try bagModelController.remove(purchasable, quantity: 1)
	}
	
	func delete(at indexPath: IndexPath) throws {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		try bagModelController.remove(purchasable)
	}
	
	func clear() { bagModelController.clearAllPurchasables() }
	
	func foodViewModelParcel(for indexPath: IndexPath) -> ItemsViewModelParcel? {
		guard let itemedPurchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable as? ItemedPurchasable else { return nil }
		return ItemsViewModelParcel(itemedPurchasable: itemedPurchasable)
	}
}
