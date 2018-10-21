//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Dressing: ModifiableFoodItem {
    let name: String
    let description: String
    let modifiers: [Modifier]
}

extension Dressing: Hashable {}

extension Dressing: ArrayBuildable {
	typealias ArrayBuilder = [Dressing : [Modifier : Bool]]
	
	static func buildArray(from builder: ArrayBuilder) -> [Dressing] {
		let filteredDressings = builder.filter { _, mods in mods.contains { $1 } }.keys
		return filteredDressings.compactMap { dressing in
			guard let modifierKeys = builder[dressing]?.filter({ $1 }).keys else { return nil }
			return Dressing(name: dressing.name, description: dressing.description, modifiers: Array(modifierKeys))
		}
	}
}
