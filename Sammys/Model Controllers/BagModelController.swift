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
    fileprivate typealias PurchasableQuantitiesDictionary = [AnyHashableProtocol : Int]
	
	private let userDefaults: UserDefaults
	
	private struct Constants { static let purchasableQuantitiesKey = "BagModelController.purchasableQuantities" }
	
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}
	
	private func purchasableQuantities(for dictionary: PurchasableQuantitiesDictionary) -> [PurchasableQuantity] {
		return dictionary.compactMap {
			guard let purchasable = $0.key.base as? Purchasable else { return nil }
			return PurchasableQuantity(quantity: $0.value, purchasable: purchasable)
		}
	}
	
	private func store(_ dictionary: PurchasableQuantitiesDictionary) throws {
		userDefaults.set(
			try JSONEncoder().encode(purchasableQuantities(for: dictionary)),
			forKey: Constants.purchasableQuantitiesKey
		)
	}
	
	func getPurchasableQuantities() throws -> [PurchasableQuantity] {
		if let purchasableQuantitiesData = userDefaults.data(forKey: Constants.purchasableQuantitiesKey) {
			do { return try JSONDecoder().decode([PurchasableQuantity].self, from: purchasableQuantitiesData) }
			catch { throw error }
		} else { throw BagModelControllerError.cantGetNeccessaryDataFromKey }
	}
	
	private func storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary(_ modifiedDictionary: (PurchasableQuantitiesDictionary) -> PurchasableQuantitiesDictionary) throws {
		try store(modifiedDictionary((try? getPurchasableQuantities())?.toDictionary() ?? PurchasableQuantitiesDictionary()))
	}
	
	private func storeModifiedStoredPurchasableQuantitiesDictionary(_ modifiedDictionary: (PurchasableQuantitiesDictionary) -> PurchasableQuantitiesDictionary) throws {
		guard let dictionary = (try? getPurchasableQuantities())?.toDictionary()
			else { return }
		try store(modifiedDictionary(dictionary))
	}
	
	func set(_ purchasable: Purchasable, toQuantity quantity: Int) throws {
		do { try storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary { $0.settingAndRemovingNonPositiveValued(AnyHashableProtocol(purchasable), to: quantity) } }
		catch { throw error }
	}
	
	func add(_ purchasable: Purchasable, quantity: Int = 1) throws {
		do { try storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary { $0.setting(AnyHashableProtocol(purchasable), toInitialValue: quantity, orIncrementingBy: quantity) } }
		catch { throw error }
    }
	
	func remove(_ purchasable: Purchasable, quantity: Int) throws {
		do { try storeModifiedStoredPurchasableQuantitiesDictionary { $0.decrementingAndRemovingNonPositiveValued(AnyHashableProtocol(purchasable), by: quantity) } }
		catch { throw error }
	}
	
	func remove(_ purchasable: Purchasable) throws {
		do {
			try storeModifiedStoredPurchasableQuantitiesDictionary {
				var dictionary = $0
				dictionary[AnyHashableProtocol(purchasable)] = nil
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
		userDefaults.removeObject(forKey: Constants.purchasableQuantitiesKey)
	}
}

private extension Array where Element == PurchasableQuantity {
	func toDictionary() -> BagModelController.PurchasableQuantitiesDictionary {
		return BagModelController.PurchasableQuantitiesDictionary(uniqueKeysWithValues: map { (AnyHashableProtocol($0.purchasable), $0.quantity) })
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
