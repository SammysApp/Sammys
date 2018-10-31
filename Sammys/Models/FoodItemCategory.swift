//
//  FoodItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol FoodItemCategory {
	var name: String { get }
}

extension FoodItemCategory where Self: RawRepresentable, Self.RawValue == String {
	var name: String {
		return rawValue
	}
}
