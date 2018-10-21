//
//  SammysTests.swift
//  SammysTests
//
//  Created by Natanel Niazoff on 7/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import XCTest
@testable import Sammys

class SammysTests: XCTestCase {
	func testBuildSalad() throws {
		let modifier = Modifier(title: "Test", price: nil)
		let size = Size(name: "Regular", description: "", price: 0.0)
		let lettuce = Lettuce(name: "Romaine", description: "", modifiers: [modifier])
		let vegetable = Vegetable(name: "Avocado", description: "")
		let topping = Topping(name: "Pine Nuts", description: "", price: nil)
		let dressing = Dressing(name: "Caeser", description: "", modifiers: [modifier])
		let extra = Extra(name: "Cheese", description: "", price: nil, modifiers: [modifier])
		
		let salad = Salad(
			size: size,
			lettuce: [lettuce],
			vegetables: [vegetable],
			toppings: [topping],
			dressings: [dressing],
			extras: [extra]
		)
		
		let builtSalad = try SaladBuilder(
			size: size,
			lettuceBuilder: [lettuce: [modifier: true]],
			vegetablesBuilder: [vegetable: true],
			toppingsBuilder: [topping: true],
			dressingsBuilder: [dressing: [modifier: true]],
			extrasBuilder: [extra: [modifier: true]]
		).build()
		
		XCTAssertEqual(salad, builtSalad)
	}
}
