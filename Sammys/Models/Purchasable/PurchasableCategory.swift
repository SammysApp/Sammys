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

// MARK: - Hashable
extension PurchasableCategory: Hashable {}

// MARK: - Codable
extension PurchasableCategory: Codable {}
