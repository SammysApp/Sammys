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
	private func getSizes() -> Promise<[Size]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.sizes.rawValue
		])
	}
	
	private func getLettuces() -> Promise<[Lettuce]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.lettuces.rawValue
		])
	}
	
	private func getVegetables() -> Promise<[Vegetable]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.vegetables.rawValue
		])
	}
	
	private func getToppings() -> Promise<[Topping]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.toppings.rawValue
		])
	}
	
	private func getDressings() -> Promise<[Dressing]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.dressings.rawValue
		])
	}
	
	private func getExtras() -> Promise<[Extra]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.extras.rawValue
		])
	}
	
	func getItems(for itemCategory: ItemCategory) -> Promise<[Item]> {
		guard let saladItemCategory = SaladItemCategory(rawValue: itemCategory.rawValue)
			else { return Promise(error: SaladItemsFetcherError.itemCategoryNotFound) }
		switch saladItemCategory {
		case .size: return getSizes().mapValues { $0 as Item }
		case .lettuce: return getLettuces().mapValues { $0 as Item }
		case .vegetable: return getVegetables().mapValues { $0 as Item }
		case .topping: return getToppings().mapValues { $0 as Item }
		case .dressing: return getDressings().mapValues { $0 as Item }
		case .extra: return getExtras().mapValues { $0 as Item }
		}
	}
}

extension Salad: ItemsFetchable {
	static var fetcher: ItemsFetcher { return SaladItemsFetcher() }
}
