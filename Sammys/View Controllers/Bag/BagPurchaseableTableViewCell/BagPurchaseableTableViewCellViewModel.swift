//
//  BagPurchaseableTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct BagPurchaseableTableViewCellViewModel: TableViewCellViewModel {
	let purchaseable: Purchaseable
	let identifier: String
	let height: Double
	let isEditable: Bool
	let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
