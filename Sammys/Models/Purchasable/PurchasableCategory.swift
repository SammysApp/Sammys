//
//  PurchasableCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CategorizedPurchasables {
	let category: PurchasableCategory
	let purchasables: [Purchasable]
}

enum PurchasableCategory: String {
	case salad
}

extension PurchasableCategory {
	var purchasableType: Purchasable.Type {
		switch self {
		case .salad: return Salad.self
		}
	}
}

extension PurchasableCategory {
	var name: String { return rawValue.capitalizingFirstLetter() }
}

// MARK: - Hashable
extension PurchasableCategory: Hashable {}
