//
//  ItemedPurchasable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ItemedPurchasable: Purchasable {
	var items: [AnyItemCategory : [AnyItem]] { get }
}
