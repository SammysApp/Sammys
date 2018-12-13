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
    fileprivate typealias PurchasableQuantitiesDictionary = [AnyPurchasable : Int]
	
	private let userDefaults: UserDefaults
	
	private struct Constants { static let purchasableQuantitiesKey = "BagModelController.purchasableQuantities" }
	
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}
}

extension BagModelController {
	private func purchasableQuantities(for dictionary: PurchasableQuantitiesDictionary) -> [PurchasableQuantity] {
		return dictionary.map { PurchasableQuantity(quantity: $0.value, purchasable: $0.key.purchasable) }
	}
}

extension BagModelController {
	private func store(_ dictionary: PurchasableQuantitiesDictionary) throws {
		userDefaults.set(
			try JSONEncoder().encode(purchasableQuantities(for: dictionary)),
			forKey: Constants.purchasableQuantitiesKey
		)
	}
	
	private func storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary(_ modifiedDictionary: (PurchasableQuantitiesDictionary) -> PurchasableQuantitiesDictionary) throws {
		try store(modifiedDictionary((try? getPurchasableQuantities())?.toDictionary() ?? PurchasableQuantitiesDictionary()))
	}
	
	private func storeModifiedStoredPurchasableQuantitiesDictionary(_ modifiedDictionary: (PurchasableQuantitiesDictionary) -> PurchasableQuantitiesDictionary) throws {
		guard let dictionary = (try? getPurchasableQuantities())?.toDictionary()
			else { return }
		try store(modifiedDictionary(dictionary))
	}
}

extension BagModelController {
	func getPurchasableQuantities() throws -> [PurchasableQuantity] {
		if let purchasableQuantitiesData = userDefaults.data(forKey: Constants.purchasableQuantitiesKey) {
			do { return try JSONDecoder().decode([PurchasableQuantity].self, from: purchasableQuantitiesData) }
			catch { throw error }
		} else { throw BagModelControllerError.cantGetNeccessaryDataFromKey }
	}
}

extension BagModelController {
	func set(_ purchasable: Purchasable, toQuantity quantity: Int) throws {
		do { try storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary { $0.settingAndRemovingNonPositiveValued(AnyPurchasable(purchasable), to: quantity) } }
		catch { throw error }
	}
	
	func update(_ oldPurchasable: Purchasable, to newPurchasable: Purchasable) throws {
		do { try storeModifiedStoredPurchasableQuantitiesDictionary { $0.switchingKey(AnyPurchasable(oldPurchasable), to: AnyPurchasable(newPurchasable)) } }
		catch { throw error }
	}
	
	func add(_ purchasable: Purchasable, quantity: UInt = 1) throws {
		do { try storeModifiedStoredOrCreatedPurchasableQuantitiesDictionary { $0.setting(AnyPurchasable(purchasable), toInitialValue: quantity, orIncrementingBy: quantity) } }
		catch { throw error }
	}
	
	func remove(_ purchasable: Purchasable, quantity: Int) throws {
		do { try storeModifiedStoredPurchasableQuantitiesDictionary { $0.decrementingAndRemovingNonPositiveValued(AnyPurchasable(purchasable), by: quantity) } }
		catch { throw error }
	}
	
	func remove(_ purchasable: Purchasable) throws {
		do {
			try storeModifiedStoredPurchasableQuantitiesDictionary {
				var dictionary = $0
				dictionary[AnyPurchasable(purchasable)] = nil
				return dictionary
			}
		} catch { throw error }
	}
	
	func clearAllPurchasables() {
		userDefaults.removeObject(forKey: Constants.purchasableQuantitiesKey)
	}
}

private extension Array where Element == PurchasableQuantity {
	func toDictionary() -> BagModelController.PurchasableQuantitiesDictionary {
		return BagModelController.PurchasableQuantitiesDictionary(uniqueKeysWithValues: map { (AnyPurchasable($0.purchasable), $0.quantity) })
	}
}

private extension Dictionary where Key == AnyPurchasable, Value == Int {
	func settingAndRemovingNonPositiveValued(_ key: AnyPurchasable, to value: Int) -> [AnyPurchasable : Int] {
		var dictionary = self
		dictionary[key] = value > 0 ? value : nil
		return dictionary
	}
	
	func setting(_ key: AnyPurchasable, toInitialValue initialValue: UInt, orIncrementingBy incrementValue: UInt) -> [AnyPurchasable : Int] {
		var dictionary = self
		if let currentValue = dictionary[key] { dictionary[key] = currentValue + Int(incrementValue) }
		else { dictionary[key] = Int(initialValue) }
		return dictionary
	}
	
	func decrementingAndRemovingNonPositiveValued(_ key: AnyPurchasable, by value: Int) -> [AnyPurchasable : Int] {
		let dictionary = self
		if let currentValue = dictionary[key] {
			return dictionary.settingAndRemovingNonPositiveValued(key, to: currentValue - value)
		}
		return dictionary
	}
}
