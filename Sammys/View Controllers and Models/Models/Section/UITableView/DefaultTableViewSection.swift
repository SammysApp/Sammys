//
//  DefaultTableViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct DefaultTableViewSection<T: TableViewCellViewModel>: Section {
	typealias CellViewModel = T
	
	let title: String?
	let cellViewModels: [CellViewModel]
	
	init(title: String? = nil, cellViewModels: [CellViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
