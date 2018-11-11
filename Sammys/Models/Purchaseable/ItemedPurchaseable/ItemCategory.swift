//
//  ItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CategorizedItems {
	let category: ItemCategory
	let items: [Item]
}

protocol ItemCategory: ProtocolHashable {
	var rawValue: String { get }
	var name: String { get }
}

extension ItemCategory where Self: RawRepresentable, Self.RawValue == String {
	var name: String { return rawValue.capitalizingFirstLetter() }
}
