//
//  OrdersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum OrderCellIdentifier: String {
	case orderCell
}

struct OrdersViewModelParcel {
	let user: User
}

protocol OrdersViewModelViewDelegate {
	func cellHeight() -> Double
}

class OrdersViewModel {
	typealias Section = TableViewSection<DefaultTableViewCellViewModel>
	private let parcel: OrdersViewModelParcel
	private let viewDelegate: OrdersViewModelViewDelegate
	
	private let ordersAPIManager = OrdersAPIManager()
	private var orders = [Order]()
	
	private var sections: [Section] { return [
		Section(cellViewModels: orders.map { OrderTableViewCellViewModelFactory(identifier: OrderCellIdentifier.orderCell.rawValue, height: viewDelegate.cellHeight(), order: $0).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: OrdersViewModelParcel, viewDelegate: OrdersViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func setupData() -> Promise<Void> {
		return ordersAPIManager.orders(for: parcel.user)
			.get { self.orders = $0 }.asVoid()
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
	}
}
