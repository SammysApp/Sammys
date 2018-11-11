//
//  SaladFoodItemsDataFetcher.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum SaladFoodItemsDataFetcherError: Error {
	case foodItemCategoryNotFound
}

struct SaladFoodItemsDataFetcher: FoodItemsDataFetcher {
	private static func getSizes() -> Promise<[Size]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.sizes.rawValue
		])
	}
	
	private static func getLettuces() -> Promise<[Lettuce]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.lettuces.rawValue
		])
	}
	
	private static func getVegetables() -> Promise<[Vegetable]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.vegetables.rawValue
		])
	}
	
	private static func getToppings() -> Promise<[Topping]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.toppings.rawValue
		])
	}
	
	private static func getDressings() -> Promise<[Dressing]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.dressings.rawValue
		])
	}
	
	private static func getExtras() -> Promise<[Extra]> {
		return DataAPIManager.getFoodItems(parameters: [
			FoodAPIKey.name.rawValue: FoodAPIName.salad.rawValue,
			FoodAPIKey.items.rawValue: SaladAPIItems.extras.rawValue
		])
	}
	
	static func getFoodItems(for foodItemCategory: FoodItemCategory) -> Promise<[FoodItem]> {
		guard let saladFoodItemCategory = SaladFoodItemCategory(rawValue: foodItemCategory.rawValue) else { return Promise(error: SaladFoodItemsDataFetcherError.foodItemCategoryNotFound) }
		switch saladFoodItemCategory {
		case .size: return getSizes().mapValues { $0 as FoodItem }
		case .lettuce: return getLettuces().mapValues { $0 as FoodItem }
		case .vegetable: return getVegetables().mapValues { $0 as FoodItem }
		case .topping: return getToppings().mapValues { $0 as FoodItem }
		case .dressing: return getDressings().mapValues { $0 as FoodItem }
		case .extra: return getExtras().mapValues { $0 as FoodItem }
		}
	}
}
