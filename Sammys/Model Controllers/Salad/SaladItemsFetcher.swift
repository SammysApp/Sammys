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
	private let saladType = Salad.title.lowercased()
	
	private func items<T: Item>(for itemCategory: ItemCategory) -> Promise<[T]> {
		return dataAPIManager.purchasables(for: saladType, category: itemCategory.rawValue)
	}
	
	private func sizes() -> Promise<[Size]>
		{ return items(for: Size.category) }
	private func lettuces() -> Promise<[Lettuce]>
		{ return items(for: Lettuce.category) }
	private func vegetables() -> Promise<[Vegetable]>
		{ return items(for: Vegetable.category) }
	private func toppings() -> Promise<[Topping]>
		{ return items(for: Topping.category) }
	private func dressings() -> Promise<[Dressing]>
		{ return items(for: Dressing.category) }
	private func extras() -> Promise<[Extra]>
		{ return items(for: Extra.category) }
	
	func items(for itemCategory: ItemCategory) -> Promise<[Item]> {
		guard let saladItemCategory = SaladItemCategory(rawValue: itemCategory.rawValue)
			else { return Promise(error: SaladItemsFetcherError.itemCategoryNotFound) }
		switch saladItemCategory {
		case .sizes: return sizes().mapValues { $0 as Item }
		case .lettuces: return lettuces().mapValues { $0 as Item }
		case .vegetables: return vegetables().mapValues { $0 as Item }
		case .toppings: return toppings().mapValues { $0 as Item }
		case .dressings: return dressings().mapValues { $0 as Item }
		case .extras: return extras().mapValues { $0 as Item }
		}
	}
}

extension Salad: ItemsFetchable {
	static var fetcher: ItemsFetcher { return SaladItemsFetcher() }
}
