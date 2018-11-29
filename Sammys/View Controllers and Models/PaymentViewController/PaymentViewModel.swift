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
	let tax: Double
	let total: Double
}

class PaymentViewModel {
	var parcel: PaymentViewModelParcel?
	
	var subtotalText: String? { return parcel?.subtotal.priceString }
	var taxText: String? { return parcel?.tax.priceString }
	var payText: String? { guard let total = parcel?.total else { return nil }; return "Pay \(total.priceString)" }
	
	init(_ parcel: PaymentViewModelParcel?) {
		self.parcel = parcel
	}
}
