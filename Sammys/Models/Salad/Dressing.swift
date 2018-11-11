//
//  Dressing.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Dressing: ModifiableItem {
	static let itemName = SaladItemCategory.dressing.rawValue
    let name: String
    let description: String
    let modifiers: [Modifier]
}

// MARK: - Hashable
extension Dressing: Hashable {}
