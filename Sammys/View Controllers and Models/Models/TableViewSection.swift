//
//  TableViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct TableViewSection<ViewModel: TableViewCellViewModel> {
	typealias CellViewModel = ViewModel
	
	let title: String?
	let cellViewModels: [ViewModel]
	
	init(title: String? = nil, cellViewModels: [ViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
