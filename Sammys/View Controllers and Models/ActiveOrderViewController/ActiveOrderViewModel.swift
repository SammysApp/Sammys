//
//  ActiveOrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct ActiveOrderViewModelParcel {
	let order: Order
}

protocol ActiveOrderViewModelViewDelegate {
	func cellHeight(for cellIdentifier: ActiveOrderCellIdentifier) -> Double
}

enum ActiveOrderCellIdentifier: String {
	case orderCell, mapCell
}

class ActiveOrderViewModel {
	typealias Section = AnyViewModelTableViewSection
	
	private let parcel: ActiveOrderViewModelParcel
	private let viewDelegate: ActiveOrderViewModelViewDelegate
	
	private var sections: [Section] { return [
		Section(cellViewModels: [
			ActiveOrderMapTableViewCellViewModelFactory(identifier: ActiveOrderCellIdentifier.mapCell.rawValue, height: viewDelegate.cellHeight(for: .mapCell)).create()
		]),
		Section(cellViewModels: [
			ActiveOrderOrderTableViewCellViewModelFactory(order: self.parcel.order, identifier: ActiveOrderCellIdentifier.orderCell.rawValue, height: viewDelegate.cellHeight(for: .orderCell)).create()
		])
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: ActiveOrderViewModelParcel, viewDelegate: ActiveOrderViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
}
