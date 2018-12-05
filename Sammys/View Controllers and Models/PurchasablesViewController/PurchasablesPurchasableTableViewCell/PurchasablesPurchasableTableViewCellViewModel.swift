//
//  PurchasablesPurchasableTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasablesPurchasableTableViewCellViewModel: TableViewCellViewModel {
	let purchasable: Purchasable
	let identifier: String
	let height: Double
	let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
