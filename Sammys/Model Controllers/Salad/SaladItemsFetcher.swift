//
//  SaladItemsFetcher.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum SaladItemsFetcherError: Error {
	case itemCategoryNotFound
}

private struct SaladItemsFetcher: ItemsFetcher {
	private func sizes() -> Promise<[Size]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.sizes.rawValue
		])
	}
	
	private func lettuces() -> Promise<[Lettuce]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.lettuces.rawValue
		])
	}
	
	private func vegetables() -> Promise<[Vegetable]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.vegetables.rawValue
		])
	}
	
	private func toppings() -> Promise<[Topping]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.toppings.rawValue
		])
	}
	
	private func dressings() -> Promise<[Dressing]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.dressings.rawValue
		])
	}
	
	private func extras() -> Promise<[Extra]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.extras.rawValue
		])
	}
	
	func items(for itemCategory: ItemCategory) -> Promise<[Item]> {
		guard let saladItemCategory = SaladItemCategory(rawValue: itemCategory.rawValue)
			else { return Promise(error: SaladItemsFetcherError.itemCategoryNotFound) }
		switch saladItemCategory {
		case .size: return sizes().mapValues { $0 as Item }
		case .lettuce: return lettuces().mapValues { $0 as Item }
		case .vegetable: return vegetables().mapValues { $0 as Item }
		case .topping: return toppings().mapValues { $0 as Item }
		case .dressing: return dressings().mapValues { $0 as Item }
		case .extra: return extras().mapValues { $0 as Item }
		}
	}
}

extension Salad: ItemsFetchable {
	static var fetcher: ItemsFetcher { return SaladItemsFetcher() }
}
