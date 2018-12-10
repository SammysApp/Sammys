//
//  BasicPurchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct BasicPurchasable: Purchasable {
	let category: PurchasableCategory
	let title: String
	let description: String
	let price: Double
}

// MARK: - Hashable
extension BasicPurchasable: Hashable {}
