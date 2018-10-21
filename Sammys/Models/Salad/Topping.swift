//
//  Topping.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Topping: OptionallyPricedItem {
    let name: String
    let description: String
    let price: Double?
}

extension Topping: Buildable {
	typealias ArrayBuilder = [Topping : Bool]
	
	static func buildArray(from builder: ArrayBuilder) -> [Topping] { return Array(builder.filter { $1 }.keys) }
}
