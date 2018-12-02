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
	let paymentMethodName: String?
}

class PaymentViewModel {
	var parcel: PaymentViewModelParcel?
	
	var subtotalTitle: String? { return parcel?.subtotal.priceString }
	var taxTitle: String? { return parcel?.tax.priceString }
	var payTitle: String? { guard let total = parcel?.total else { return nil }; return "Pay \(total.priceString)" }
	var paymentMethodTitle: String? { return parcel?.paymentMethodName }
	
	init(_ parcel: PaymentViewModelParcel?) {
		self.parcel = parcel
	}
}
