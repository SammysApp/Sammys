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
	private let dataAPIManager = DataAPIManager()
	
	private func sizes() -> Promise<[Size]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.sizes.rawValue)
	}
	
	private func lettuces() -> Promise<[Lettuce]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.lettuces.rawValue)
	}
	
	private func vegetables() -> Promise<[Vegetable]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.vegetables.rawValue)
	}
	
	private func toppings() -> Promise<[Topping]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.toppings.rawValue)
	}
	
	private func dressings() -> Promise<[Dressing]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.dressings.rawValue)
	}
	
	private func extras() -> Promise<[Extra]> {
		return dataAPIManager.getPurchasableItems(for: .salad, items: SaladAPIItems.extras.rawValue)
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
