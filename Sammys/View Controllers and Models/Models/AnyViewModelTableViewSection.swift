//
//  AnyViewModelTableViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct AnyViewModelTableViewSection {
	typealias CellViewModel = TableViewCellViewModel
	
	let title: String?
	let cellViewModels: [CellViewModel]
	
	init(title: String? = nil, cellViewModels: [CellViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
