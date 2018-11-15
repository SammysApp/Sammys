//
//  CollectionViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CollectionViewSection<T: CollectionViewCellViewModel> {
	typealias CellViewModel = T
	
	let title: String?
	let cellViewModels: [CellViewModel]
	
	init(title: String? = nil, cellViewModels: [CellViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
