//
//  Purchaseable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Purchaseable: ProtocolHashable, ProtocolCodable {
	var price: Double { get }
}
