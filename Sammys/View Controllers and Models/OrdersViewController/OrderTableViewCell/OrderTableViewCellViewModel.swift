//
//  OrderTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrderTableViewCellViewModel: TableViewCellViewModel {
	let order: Order
	let identifier: String
	let height: Double
	let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
