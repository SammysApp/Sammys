//
//  Item.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol Item: Codable, Hashable {
	var name: String { get }
    var description: String { get }
}

protocol PricedItem: Item {
	var price: Double { get }
}

/// Use in cases where instances can either be priced or be free.
protocol OptionallyPricedItem: Item {
	var price: Double? { get }
}

protocol ModifiableItem: Item {
	var modifiers: [Modifier] { get }
}

protocol Buildable where Self: Item {
	associatedtype ArrayBuilder
	static func buildArray(from builder: ArrayBuilder) -> [Self]
}
