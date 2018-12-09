//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad: ItemedPurchasable {
	let items: [AnyItemCategory : [AnyItem]]
	
	let category: PurchasableCategory
	let isTaxSubjected: Bool
	
	var title: String { return "" }
	var description: String { return "" }
	var price: Double { return 0 }
}

// MARK: - Hashable
extension Salad: Hashable {}
