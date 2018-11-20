//
//  Price.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Price: Codable {
	let tax: Double?
	let discount: Double?
	let total: Double
	
	init(taxPrice: Double? = nil, discount: Double? = nil, totalPrice: Double) {
		self.tax = taxPrice
		self.discount = discount
		self.total = totalPrice
	}
}
