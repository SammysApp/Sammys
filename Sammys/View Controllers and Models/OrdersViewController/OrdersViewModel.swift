//
//  OrdersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct OrdersViewModelParcel {
	let user: User
}

protocol OrdersViewModelViewDelegate {
	func cellHeight() -> Double
}

enum OrdersCellIdentifier: String {
	case orderCell
}

enum OrdersViewModelError: Error {
	case needsParcel
}

class OrdersViewModel {
	typealias Section = DefaultTableViewSection<OrderTableViewCellViewModel>
	
	var parcel: OrdersViewModelParcel?
	private let viewDelegate: OrdersViewModelViewDelegate
	
	private let ordersAPIManager = OrdersAPIManager()
	
	private var orders = [Order]()
	private var sections: [Section] { return [
		Section(cellViewModels: orders.map { OrderTableViewCellViewModelFactory(order: $0, identifier: OrdersCellIdentifier.orderCell.rawValue, height: viewDelegate.cellHeight()).create() })
	]}
	
	var numberOfSections: Int { return sections.count }
	
	init(parcel: OrdersViewModelParcel?, viewDelegate: OrdersViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func setupData() -> Promise<Void> {
		guard let parcel = parcel else { return Promise(error: OrdersViewModelError.needsParcel) }
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
