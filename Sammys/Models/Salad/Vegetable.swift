//
//  Vegetable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Vegetable: FoodItem {
    let name: String
    let description: String
}

extension Vegetable: Hashable {}

extension Vegetable: ArrayBuildable {
	typealias ArrayBuilder = [Vegetable : Bool]
	
	static func buildArray(from builder: ArrayBuilder) -> [Vegetable] { return Array(builder.filter { $1 }.keys) }
}
