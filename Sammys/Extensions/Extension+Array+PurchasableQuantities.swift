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
	
	var totalPrice: Double { return reduce(0) { $0 + $1.quantitativePrice } }
	
	var totalTaxPrice: Double { return filter { $0.purchasable.isTaxSubjected }.reduce(0) { $0 + $1.quantitativePrice.taxPrice }.priceRounded() }
	
	var totalTaxedPrice: Double { return totalPrice + totalTaxPrice }
}
