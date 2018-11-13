//
//  PaymentViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PaymentViewModelParcel {
	let subtotal: Double
}

class PaymentViewModel {
	private let parcel: PaymentViewModelParcel
	
	private var subtotal: Double { return parcel.subtotal }
	private var tax: Double { return parcel.subtotal * Constants.taxRateMultiplier }
	private var total: Double { return subtotal + tax }
	
	var subtotalText: String { return subtotal.priceString }
	var taxText: String { return tax.priceString }
	var payText: String { return "Pay \(total.priceString)" }
	
	private struct Constants {
		static let taxRateMultiplier: Double = 0.06625
	}
	
	init(_ parcel: PaymentViewModelParcel) {
		self.parcel = parcel
	}
}
