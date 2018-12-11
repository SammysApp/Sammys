//
//  PurchasableCategoryTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoryTableViewCellViewModel: TableViewCellViewModel {
	let category: PurchasableCategoryNode
	let identifier: String
	let height: Double
	let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
