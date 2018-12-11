//
//  Extension+Array+PurchasableQuantities.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension Array where Element == PurchasableQuantity {
	var totalQuantity: Int { return reduce(0) { $0 + $1.quantity } }
	
	var totalPrice: Double { return 0 }
	
	var totalTaxPrice: Double { return 0 }
	
	var totalTaxedPrice: Double { return totalPrice + totalTaxPrice }
}
