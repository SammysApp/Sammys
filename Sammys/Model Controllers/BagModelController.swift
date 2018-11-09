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
    fileprivate typealias PurchaseableQuantitiesDictionary = [AnyHashableProtocol : Int]
	
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
	
	private func storeModifiedStoredOrCreatedPurchaseableQuantitiesDictionary(_ modifiedDictionary: (PurchaseableQuantitiesDictionary) -> PurchaseableQuantitiesDictionary) throws {
		try store(modifiedDictionary((try? getPurchasableQuantities())?.toDictionary() ?? PurchaseableQuantitiesDictionary()))
	}
	
	private func storeModifiedStoredPurchaseableQuantitiesDictionary(_ modifiedDictionary: (PurchaseableQuantitiesDictionary) -> PurchaseableQuantitiesDictionary) throws {
		guard let dictionary = (try? getPurchasableQuantities())?.toDictionary()
			else { return }
		try store(modifiedDictionary(dictionary))
	}
	
	func set(_ purchaseable: Purchaseable, toQuantity quantity: Int) throws {
		do { try storeModifiedStoredOrCreatedPurchaseableQuantitiesDictionary { $0.settingAndRemovingNonPositiveValued(AnyHashableProtocol(purchaseable), to: quantity) } }
		catch { throw error }
	}
	
	func add(_ purchaseable: Purchaseable, quantity: Int = 1) throws {
		do { try storeModifiedStoredOrCreatedPurchaseableQuantitiesDictionary { $0.setting(AnyHashableProtocol(purchaseable), toInitialValue: quantity, orIncrementingBy: quantity) } }
		catch { throw error }
    }
	
	func remove(_ purchaseable: Purchaseable, quantity: Int) throws {
		do { try storeModifiedStoredPurchaseableQuantitiesDictionary { $0.decrementingAndRemovingNonPositiveValued(AnyHashableProtocol(purchaseable), by: quantity) } }
		catch { throw error }
	}
	
	func remove(_ purchaseable: Purchaseable) throws {
		do {
			try storeModifiedStoredPurchaseableQuantitiesDictionary {
				var dictionary = $0
				dictionary[AnyHashableProtocol(purchaseable)] = nil
				return dictionary
			}
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

private extension Array where Element == PurchaseableQuantity {
	func toDictionary() -> BagModelController.PurchaseableQuantitiesDictionary {
		return BagModelController.PurchaseableQuantitiesDictionary(uniqueKeysWithValues: map { (AnyHashableProtocol($0.purchaseable), $0.quantity) })
	}
}

private extension Dictionary where Key == AnyHashableProtocol, Value == Int {
	func settingAndRemovingNonPositiveValued(_ key: AnyHashableProtocol, to value: Int) -> [AnyHashableProtocol : Int] {
		var dictionary = self
		dictionary[key] = value > 0 ? value : nil
		return dictionary
	}
	
	func setting(_ key: AnyHashableProtocol, toInitialValue initialValue: Int, orIncrementingBy incrementValue: Int) -> [AnyHashableProtocol : Int] {
		var dictionary = self
		if let currentValue = dictionary[key] { dictionary[key] = currentValue + incrementValue }
		else { dictionary[key] = initialValue }
		return dictionary
	}
	
	func decrementingAndRemovingNonPositiveValued(_ key: AnyHashableProtocol, by value: Int) -> [AnyHashableProtocol : Int] {
		let dictionary = self
		if let currentValue = dictionary[key] {
			return dictionary.settingAndRemovingNonPositiveValued(key, to: currentValue - value)
		}
		return dictionary
	}
}
