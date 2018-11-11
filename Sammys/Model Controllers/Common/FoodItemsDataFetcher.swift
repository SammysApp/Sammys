//
//  FoodItemsDataFetcher.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

protocol FoodItemsDataFetcher {
	static func getFoodItems(for foodItemCategory: ItemCategory) -> Promise<[Item]>
}
