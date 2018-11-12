//
//  Purchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Purchasable: ProtocolHashable, ProtocolCodable {
	var title: String { get }
	var description: String { get }
	var price: Double { get }
}
