//
//  CollectionViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct CollectionViewSection {
	let title: String?
	let cellViewModels: [CollectionViewCellViewModel]
	
	init(title: String? = nil, cellViewModels: [CollectionViewCellViewModel]) {
		self.title = title
		self.cellViewModels = cellViewModels
	}
}
