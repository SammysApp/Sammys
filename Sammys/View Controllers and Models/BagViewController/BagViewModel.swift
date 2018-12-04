//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import Stripe

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
	case badCellViewModelIndexPath, needsUser, needsStripeID
}

class BagViewModel {
	typealias Section = DefaultTableViewSection<BagPurchasableTableViewCellViewModel>
	
	var parcel: BagViewModelParcel?
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
	
	lazy var userState = { parcel?.userState ?? .noUser }()
	var user: User? {
		guard case .currentUser(let user) = userState else { return nil }
		return user
	}
	
	var selectedPaymentMethod: STPPaymentMethod?
	
	var subtotal: Double { return purchasableQuantities.totalPrice }
	var tax: Double { return purchasableQuantities.totalTaxPrice }
	var total: Double { return purchasableQuantities.totalTaxedPrice }
	
	init(parcel: BagViewModelParcel?, viewDelegate: BagViewModelViewDelegate) {
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
	
	func completeOrderPurchase(for user: User, withSource source: String? = nil) -> Promise<Order> {
		return purchaseOrder(for: user, withSource: source).then { payment in
			self.newOrderNumber()
				.map { self.makeBagOrder(for: user, withNumber: $0, payment: payment) }
				.get(self.send)
		}
	}
	
	private func purchaseOrder(for user: User, withSource source: String? = nil) -> Promise<Order.Payment> {
		guard let customer = user.payment.ids[.stripe]
			else { return Promise(error: BagViewModelError.needsStripeID) }
		return stripeAPIManager.createCharge(amount: total.toCents(), source: source, customer: customer)
			.map { Order.Payment(id: $0.id, service: .stripe, method: Order.Payment.Method(id: $0.source.id, name: $0.source.name)) }
	}
	
	private func newOrderNumber() -> Promise<OrderNumber> {
		return ordersAPIManager.generateOrderNumber()
	}
	
	private func makeBagOrder(for user: User, withNumber number: Int, payment: Order.Payment? = nil) -> Order {
		return Order(
			number: "\(number)",
			user: Order.User(id: user.id, name: user.name),
			purchasableQuantities: purchasableQuantities,
			price: Order.Price(taxPrice: tax, totalPrice: total),
			payment: payment
		)
	}
	
	private func send(_ order: Order) throws { try ordersAPIManager.add(order) }
	
	// MARK: - Stripe
	func paymentContext(for user: User) throws -> STPPaymentContext {
		return STPPaymentContext(customerContext: try customerContext(for: user))
	}
	
	private func customerContext(for user: User) throws -> STPCustomerContext {
		guard let customer = user.payment.ids[.stripe] else { throw BagViewModelError.needsStripeID }
		return STPCustomerContext(keyProvider: EphemeralKeyProvider(customer: customer))
	}
}

private class EphemeralKeyProvider: NSObject, STPEphemeralKeyProvider {
	private let customer: String
	
	init(customer: String) {
		self.customer = customer
		super.init()
	}
	
	func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
		StripeAPIManager().createEphemeralKey(customer: customer, version: apiVersion)
			.get { completion($0, nil) }.catch { completion(nil, $0) }
	}
}
