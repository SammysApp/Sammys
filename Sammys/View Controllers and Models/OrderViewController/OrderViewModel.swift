//
//  OrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct OrderViewModelParcel {
	let order: Order
}

protocol OrderViewModelViewDelegate {
	func cellHeight() -> Double
}

enum OrderCellIdentifier: String { case purchasableCell }

class OrderViewModel {
	typealias Section = TableViewSection<OrderPurchasableTableViewCellViewModel>
	
	private let parcel: OrderViewModelParcel
	private let viewDelegate: OrderViewModelViewDelegate
	
	var sections: [Section] { return [
		Section(cellViewModels: parcel.order.purchasableQuantities.map { OrderPurchasableTableViewCellViewModelFactory(purchasableQuantity: $0, identifier: OrderCellIdentifier.purchasableCell.rawValue, height: viewDelegate.cellHeight()).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: OrderViewModelParcel, viewDelegate: OrderViewModelViewDelegate) {
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
