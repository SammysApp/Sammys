//
//  BagModelController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum BagModelControllerError: Error {
	case cantGetNeccessaryDataFromKey
}

struct BagModelController {
    private typealias PurchaseableQuantitiesDictionary = [AnyHashableProtocol : Int]
	
	private let userDefaults: UserDefaults
	
	private struct Constants { static let purchaseableQuantitiesKey = "BagModelController.purchaseableQuantities" }
	
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}
	
	private func purchaseableQuantities(for dictionary: PurchaseableQuantitiesDictionary) -> [PurchaseableQuantity] {
		return dictionary.compactMap {
			guard let purchaseable = $0.key.base as? Purchaseable else { return nil }
			return PurchaseableQuantity(quantity: $0.value, purchaseable: purchaseable)
		}
	}
	
	private func dictionary(for purchaseableQuantities: [PurchaseableQuantity]) -> PurchaseableQuantitiesDictionary {
		return PurchaseableQuantitiesDictionary(uniqueKeysWithValues: purchaseableQuantities.map { (AnyHashableProtocol($0.purchaseable), $0.quantity) })
	}
	
	private func store(_ dictionary: PurchaseableQuantitiesDictionary) throws {
		userDefaults.set(
			try JSONEncoder().encode(purchaseableQuantities(for: dictionary)),
			forKey: Constants.purchaseableQuantitiesKey
		)
	}
	
	func getPurchasableQuantities() throws -> [PurchaseableQuantity] {
		if let purchasableQuantitiesData = userDefaults.data(forKey: Constants.purchaseableQuantitiesKey) {
			do { return try JSONDecoder().decode([PurchaseableQuantity].self, from: purchasableQuantitiesData) }
			catch { throw error }
		} else { throw BagModelControllerError.cantGetNeccessaryDataFromKey }
	}
	
	func add(_ purchaseable: Purchaseable, quantity: Int = 1) throws {
		do {
			var dictionary = PurchaseableQuantitiesDictionary()
			if let purchasableQuantities = try? getPurchasableQuantities() {
				dictionary = self.dictionary(for: purchasableQuantities)
			}
			dictionary.set(AnyHashableProtocol(purchaseable), toInitialValue: quantity, orIncrementBy: quantity)
			try store(dictionary)
		} catch { throw error }
    }
	
	func remove(_ purchaseable: Purchaseable, quantity: Int = 1) throws {
		do {
			guard let purchasableQuantities = try? getPurchasableQuantities() else { return }
			var dictionary = self.dictionary(for: purchasableQuantities)
			dictionary.decrementAndRemoveNonPositiveKeyed(AnyHashableProtocol(purchaseable), by: quantity)
			try store(dictionary)
		} catch { throw error }
	}
}

extension BagModelController {
	func getTotalQuantity() throws -> Int {
		return try getPurchasableQuantities().reduce(0) { $0 + $1.quantity }
	}
	
	func clearAll() {
		userDefaults.removeObject(forKey: Constants.purchaseableQuantitiesKey)
	}
}

private extension Dictionary where Key == AnyHashableProtocol, Value == Int {
	mutating func set(_ key: AnyHashableProtocol, toInitialValue initialValue: Int, orIncrementBy incrementValue: Int) {
		if let currentValue = self[key] { self[key] = currentValue + incrementValue }
		else { self[key] = initialValue }
	}
	
	mutating func decrementAndRemoveNonPositiveKeyed(_ key: AnyHashableProtocol, by value: Int) {
		if let currentValue = self[key] {
			let newValue = currentValue - value
			self[key] = newValue > 0 ? newValue : nil
		}
	}
}
