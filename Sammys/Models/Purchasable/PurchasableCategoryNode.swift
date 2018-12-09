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
		case categoryNodes([PurchasableCategoryNode])
		case purchasables(Promise<[Purchasable]>)
		case itemedPurchasable
	}
}
