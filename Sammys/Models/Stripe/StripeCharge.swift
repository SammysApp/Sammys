//
//  StripeCharge.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct StripeCharge: Codable {
	let id: String
	let source: StripeSource
}
