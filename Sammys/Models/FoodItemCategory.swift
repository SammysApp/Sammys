//
//  FoodItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol FoodItemCategory {
	var stringValue: String { get }
	var name: String { get }
}

extension FoodItemCategory where Self: RawRepresentable, Self.RawValue == String {
	var stringValue: String {
		return rawValue
	}
	
	var name: String {
		return rawValue.capitalizingFirstLetter()
	}
}
