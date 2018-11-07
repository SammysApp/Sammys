//
//  CollectionViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CollectionViewSection<ViewModel: CollectionViewCellViewModel> {
	typealias CellViewModel = ViewModel
	
	let title: String?
	let cellViewModels: [ViewModel]
	
	init(title: String? = nil, cellViewModels: [ViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
