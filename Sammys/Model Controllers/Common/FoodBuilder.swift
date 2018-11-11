//
//  FoodBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol FoodBuilder {
	mutating func toggle(_ foodItem: Item, with modifier: Modifier?) throws
	func build() throws -> ItemedPurchaseable
	init()
}
