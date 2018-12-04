//
//  Modifier.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Modifier {
    let title: String
    let price: Double?
	let id: String
}

// MARK: - Hashable
extension Modifier: Hashable {}

// MARK: - Codable
extension Modifier: Codable {}
