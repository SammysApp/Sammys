//
//  ItemCategory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemCategory: ProtocolHashable, ProtocolCodable {
	var rawValue: String { get }
	var name: String { get }
	
	init?(rawValue: String)
}

extension ItemCategory where Self: RawRepresentable, Self.RawValue == String {
	var name: String { return rawValue.capitalizingFirstLetter() }
	init?(rawValue: String) { self.init(rawValue: rawValue) }
}
