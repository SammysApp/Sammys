//
//  SaladBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladBuilderError: Error {
	case noSize
}

struct SaladBuilder {
	var size: Size?
	var lettuceBuilder: Lettuce.ArrayBuilder
	var vegetablesBuilder: Vegetable.ArrayBuilder
	var toppingsBuilder: Topping.ArrayBuilder
	var dressingsBuilder: Dressing.ArrayBuilder
	var extrasBuilder: Extra.ArrayBuilder
	
	func build() throws -> Salad {
		guard let size = size else { throw SaladBuilderError.noSize }
		return Salad(
			size: size,
			lettuce: Lettuce.buildArray(from: lettuceBuilder),
			vegetables: Vegetable.buildArray(from: vegetablesBuilder),
			toppings: Topping.buildArray(from: toppingsBuilder),
			dressings: Dressing.buildArray(from: dressingsBuilder),
			extras: Extra.buildArray(from: extrasBuilder)
		)
	}
}
