//
//  StripeSource.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct StripeSource: Codable {
	let id: String
	let brand: String
	let last4: String
}

extension StripeSource {
	var name: String { return "\(brand) \(last4)" }
}
