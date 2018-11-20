//
//  Extension+Double.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

extension Double {
	private struct Constants {
		static let taxRateMultiplier: Double = 0.06625
	}
	
	var taxPrice: Double { return self * Constants.taxRateMultiplier }
	
	func addingTax() -> Double { return self + taxPrice }
}
