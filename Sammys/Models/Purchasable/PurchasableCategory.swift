//
//  PurchasableCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum PurchasableCategory: String {
	case salad
}

extension PurchasableCategory {
	var name: String { return rawValue.capitalizingFirstLetter() }
}

// MARK: - Codable
extension PurchasableCategory: Codable {}

// MARK: - Hashable
extension PurchasableCategory: Hashable {}
