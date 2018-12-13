//
//  PurchasableCategoryNode.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct PurchasableCategoryNode {
	let category: PurchasableCategory
	let title: String?
	let next: Next?
	
	enum Next {
		case categories([PurchasableCategoryNode])
		case purchasables(Promise<[BasicPurchasable]>)
		case itemedPurchasable(ItemedPurchasableData)
	}
	
	fileprivate struct PurchasablesRawData: Decodable {
		let path: String
	}
	
	fileprivate struct ItemedPurchasableRawData: Decodable {
		let itemCategories: [ItemCategory]
		let path: String
		let itemsPath: String
	}
	
	struct ItemedPurchasableData {
		let categories: [ItemCategory]
		let promises: [ItemCategory: Promise<[Item]>]
		let builder: ItemedPurchasableBuilder
	}
}

// MARK: - Decodable
extension PurchasableCategoryNode: Decodable {}

// MARK: - PurchasableCategoryNode.Next: Decodable
extension PurchasableCategoryNode.Next: Decodable {
	enum CodingKeys: CodingKey {
		case categories
		case purchasables
		case itemedPurchasable
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let purchasablesAPIManager = PurchasablesAPIManager()
		do {
			self = .categories(try container.decode([PurchasableCategoryNode].self, forKey: .categories))
		} catch {
			do {
				self = .purchasables(purchasablesAPIManager.purchasables(path: (try container.decode(PurchasableCategoryNode.PurchasablesRawData.self, forKey: .purchasables)).path))
			} catch {
				do {
					let itemedPurchasableData = try container.decode(PurchasableCategoryNode.ItemedPurchasableRawData.self, forKey: .itemedPurchasable)
					let promises = itemsPromises(purchasablesAPIManager: purchasablesAPIManager, path: itemedPurchasableData.itemsPath, categories: itemedPurchasableData.itemCategories)
					self = .itemedPurchasable(PurchasableCategoryNode.ItemedPurchasableData(categories: itemedPurchasableData.itemCategories, promises: promises, builder: ItemedPurchasableBuilder()))
				}
			}
		}
	}
}

func itemsPromises(purchasablesAPIManager: PurchasablesAPIManager, path: String, categories: [ItemCategory]) -> [ItemCategory: Promise<[Item]>] {
	var itemCategoryPromises = [ItemCategory: Promise<[Item]>]()
	categories.forEach { itemCategoryPromises[$0] = purchasablesAPIManager.items(path: path + "/" + $0.rawValue) }
	return itemCategoryPromises
}
