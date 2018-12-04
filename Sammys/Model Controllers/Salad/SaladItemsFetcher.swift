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
	
	private func items<T: Item>(for itemCategory: ItemCategory, of type: T.Type) -> Promise<[T]> {
		return dataAPIManager.purchasables(for: Salad.category.rawValue, category: itemCategory.rawValue)
	}
	
	private func asItems(_ items: [Item]) -> [Item] { return items }
	
	func items(for itemCategory: ItemCategory) -> Promise<[Item]> {
		guard let saladItemCategory = SaladItemCategory(rawValue: itemCategory.rawValue)
			else { return Promise(error: SaladItemsFetcherError.itemCategoryNotFound) }
		switch saladItemCategory {
		case .sizes: return items(for: itemCategory, of: Size.self).map(asItems)
		case .lettuces: return items(for: itemCategory, of: Lettuce.self).map(asItems)
		case .vegetables: return items(for: itemCategory, of: Vegetable.self).map(asItems)
		case .toppings: return items(for: itemCategory, of: Topping.self).map(asItems)
		case .dressings: return items(for: itemCategory, of: Dressing.self).map(asItems)
		case .extras: return items(for: itemCategory, of: Extra.self).map(asItems)
		}
	}
}

extension Salad: ItemsFetchable {
	static var fetcher: ItemsFetcher { return SaladItemsFetcher() }
}
