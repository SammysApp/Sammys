//
//  Modifiers.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Modifiers {
	let modifiers: [Modifier]
	let builderRules: ModifiersBuilderRules?
}

// MARK: - Decodable
extension Modifiers: Decodable {}
