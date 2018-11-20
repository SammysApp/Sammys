//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum BagViewModelError: Error {
	case badCellViewModelIndexPath
}

struct BagViewModelParcel {
	let userState: UserState
}

protocol BagViewModelViewDelegate {
	func cellHeight() -> Double
}

class BagViewModel {
	typealias Section = TableViewSection<BagPurchasableTableViewCellViewModel>
	
	private let parcel: BagViewModelParcel
	private let viewDelegate: BagViewModelViewDelegate
	var bagPurchasableTableViewCellDelegate: BagPurchasableTableViewCellDelegate?
	
	private let ordersAPIManager = OrdersAPIManager()
	
	private let bagModelController = BagModelController()
	private var purchasableQuantities: [PurchasableQuantity] {
		do { return try bagModelController.getPurchasableQuantities() }
		catch { print(error); return [] }
	}
	
	var user: User? { guard case .currentUser(let user) = parcel.userState else { return nil }; return user }
	
	private var subtotal: Double { return purchasableQuantities.totalPrice }
	private var tax: Double { return purchasableQuantities.totalTaxPrice }
	private var total: Double { return purchasableQuantities.totalTaxedPrice }
	
	private var sections: [Section] { return [
		Section(cellViewModels: purchasableQuantities
			.map { BagPurchasableTableViewCellViewModelFactory(purchasableQuantity: $0, height: viewDelegate.cellHeight(), delegate: bagPurchasableTableViewCellDelegate).create() }
		)
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: BagViewModelParcel, viewDelegate: BagViewModelViewDelegate) {
		self.parcel = parcel
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
	
	private func makeBagOrder(withNumber number: Int) -> Order {
		return Order(
			id: UUID().uuidString,
			number: "\(number)",
			date: Date(),
			user: Order.User(userName: user?.name ?? "no name", userID: user?.id),
			purchasableQuantities: purchasableQuantities,
			price: Price(taxPrice: tax, totalPrice: total),
			more: nil,
			status: Order.Status()
		)
	}
	
	func sendOrder() -> Promise<Void> {
		return ordersAPIManager.generateOrderNumber()
			.get { try self.ordersAPIManager.add(self.makeBagOrder(withNumber: $0)) }.asVoid()
	}
	
	func paymentViewModelParcel() throws -> PaymentViewModelParcel {
		return PaymentViewModelParcel(subtotal: subtotal, tax: tax, total: total)
	}
	
	func itemsViewModelParcel(for indexPath: IndexPath) -> ItemsViewModelParcel? {
		guard let itemedPurchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable as? ItemedPurchasable else { return nil }
		return ItemsViewModelParcel(itemedPurchasable: itemedPurchasable)
	}
}
