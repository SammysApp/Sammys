//
//  PurchasableCategoriesTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasableCategoriesTableViewCellViewModel: TableViewCellViewModel {
	let category: PurchasableCategory
	let identifier: String
	let height: Double
	let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
