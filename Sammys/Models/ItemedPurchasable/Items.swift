//
//  Items.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Items {
	let builderRules: ItemsBuilderRules?
	let items: [Item]
}

// MARK: - Decodable
extension Items: Decodable {}
