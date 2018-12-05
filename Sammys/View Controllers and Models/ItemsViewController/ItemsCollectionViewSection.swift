//
//  ItemsCollectionViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ItemsCollectionViewSection: Section {
	typealias CellViewModel = DefaultCollectionViewCellViewModel
	
	let category: ItemCategory
	let cellViewModels: [CellViewModel]
}

extension ItemsCollectionViewSection {
	var title: String? { return category.name }
}
