//
//  OrdersViewModel.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol OrdersViewModelDelegate {
    func needsUIUpdate()
}

class OrdersViewModel {
    var delegate: OrdersViewModelDelegate?
    let id = UUID().uuidString
    
    private var kitchenOrders: [KitchenOrder]? {
        didSet {
            delegate?.needsUIUpdate()
        }
    }
    
    private var cellViewModels: [TableViewCellViewModel]? {
        // Result of sorting kitchen orders by date and mapping to models.
        return kitchenOrders?.sorted { $0.order.date.compare($1.order.date) == .orderedDescending }.map { OrderTableViewCellViewModelFactory(kitchenOrder: $0).create() }
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    init() {
        OrdersAPIClient.addObserver(self)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return cellViewModels?.count ?? 0
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
        return cellViewModels?[indexPath.row]
    }
}

extension OrdersViewModel: OrdersAPIObserver {
    func ordersValueDidChange(_ kitchenOrders: [KitchenOrder]) {
        self.kitchenOrders = kitchenOrders
    }
}
