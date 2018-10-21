//
//  Lettuce.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Lettuce: ModifiableFoodItem {
    let name: String
    let description: String
    let modifiers: [Modifier]
}

extension Lettuce: Hashable {}

extension Lettuce: ArrayBuildable {
	typealias ArrayBuilder = [Lettuce : [Modifier : Bool]]
	
	static func buildArray(from builder: ArrayBuilder) -> [Lettuce] {
		let filteredLettuce = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredLettuce.compactMap { lettuce in
			guard let modifierKeys = builder[lettuce]?.filter({ $1 }).keys else { return nil }
			return Lettuce(name: lettuce.name, description: lettuce.description, modifiers: Array(modifierKeys))
		}
	}
}
