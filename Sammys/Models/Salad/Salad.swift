//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Salad: Food {
	let size: Size
	let lettuce: [Lettuce]
    let vegetables: [Vegetable]
    let toppings: [Topping]
    let dressings: [Dressing]
    let extras: [Extra]
}

extension Salad: Hashable {}

extension Salad: CodableFood {
	static let codableFoodType = CodableFoodType.salad
}

extension Salad: HashableFood {}
