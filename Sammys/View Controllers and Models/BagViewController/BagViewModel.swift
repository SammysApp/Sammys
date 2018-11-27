//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct BagViewModelParcel {
	let userState: UserState
}

protocol BagViewModelViewDelegate {
	func cellHeight() -> Double
}

enum BagCellIdentifier: String {
	case purchasableCell
}

enum BagViewModelError: Error {
	case badCellViewModelIndexPath, needsUser
}

class BagViewModel {
	typealias Section = DefaultTableViewSection<BagPurchasableTableViewCellViewModel>
	
	private let parcel: BagViewModelParcel
	private let viewDelegate: BagViewModelViewDelegate
	
	private let bagModelController = BagModelController()
	private let ordersAPIManager = OrdersAPIManager()
	private let stripeAPIManager = StripeAPIManager()
	
	var bagPurchasableTableViewCellDelegate: BagPurchasableTableViewCellDelegate?
	
	// MARK: - Data
	private var sections: [Section] { return [
		Section(cellViewModels: purchasableQuantities
			.map { BagPurchasableTableViewCellViewModelFactory(purchasableQuantity: $0, identifier: BagCellIdentifier.purchasableCell.rawValue, height: viewDelegate.cellHeight(), delegate: bagPurchasableTableViewCellDelegate).create() }
		)
	]}
	
	var numberOfSections: Int { return sections.count }
	
	private var purchasableQuantities: [PurchasableQuantity] {
		do { return try bagModelController.getPurchasableQuantities() }
		catch { print(error); return [] }
	}
	
	var user: User? { guard case .currentUser(let user) = parcel.userState else { return nil }; return user }
	
	var subtotal: Double { return purchasableQuantities.totalPrice }
	var tax: Double { return purchasableQuantities.totalTaxPrice }
	var total: Double { return purchasableQuantities.totalTaxedPrice }
	
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
	
	private func purchasable(for indexPath: IndexPath) throws -> Purchasable {
		guard let purchasable = cellViewModel(for: indexPath)?.purchasableQuantity.purchasable
			else { throw BagViewModelError.badCellViewModelIndexPath }
		return purchasable
	}
	
	func set(toQuantity quantity: Int, at indexPath: IndexPath) throws {
		try bagModelController.set(try purchasable(for: indexPath), toQuantity: quantity)
	}
	
	func updatePurchasable(at indexPath: IndexPath, to newPurchasable: Purchasable) throws {
		try bagModelController.update(try purchasable(for: indexPath), to: newPurchasable)
	}
	
	func incrementQuantity(at indexPath: IndexPath) throws {
		try bagModelController.add(try purchasable(for: indexPath))
	}
	
	func decrementQuantity(at indexPath: IndexPath) throws {
		try bagModelController.remove(try purchasable(for: indexPath), quantity: 1)
	}
	
	func delete(at indexPath: IndexPath) throws {
		try bagModelController.remove(try purchasable(for: indexPath))
	}
	
	func clear() { bagModelController.clearAllPurchasables() }
	
	func completePurchase() -> Promise<Void> {
		return purchaseOrder().then { payment in
			self.newOrderNumber()
				.map { try self.makeBagOrder(withNumber: $0, payment: payment) }
				.done(self.send)
		}
	}
	
	private func purchaseOrder(withSource source: String? = nil) -> Promise<Order.Payment> {
		guard let user = user else { return Promise(error: BagViewModelError.needsUser) }
		return stripeAPIManager.createCharge(amount: total.toCents(), source: source, customer: user.payment.id)
			.map { Order.Payment(id: $0.id, service: .stripe, method: Order.Payment.Method(id: $0.source.id, name: $0.source.name)) }
	}
	
	private func newOrderNumber() -> Promise<OrderNumber> {
		return ordersAPIManager.generateOrderNumber()
	}
	
	private func makeBagOrder(withNumber number: Int, payment: Order.Payment? = nil) throws -> Order {
		guard let user = user else { throw BagViewModelError.needsUser }
		return Order(
			number: "\(number)",
			user: Order.User(userName: user.name, userID: user.id),
			purchasableQuantities: purchasableQuantities,
			price: Order.Price(taxPrice: tax, totalPrice: total),
			payment: payment
		)
	}
	
	private func send(_ order: Order) throws { try ordersAPIManager.add(order) }
}
