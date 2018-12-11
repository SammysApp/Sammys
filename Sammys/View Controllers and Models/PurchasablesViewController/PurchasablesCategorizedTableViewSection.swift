//
//  PurchasablesCategorizedTableViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PurchasablesCategorizedTableViewSection: Section {
	typealias CellViewModel = PurchasablesPurchasableTableViewCellViewModel
	
	let category: PurchasableCategory
	let cellViewModels: [CellViewModel]
}

extension PurchasablesCategorizedTableViewSection {
	var title: String? { return nil }
}
