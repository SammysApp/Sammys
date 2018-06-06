//
//  OrdersViewModel.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum OrdersViewControllerViewKey {
    case orders, foods
}

protocol OrdersViewModelDelegate {
    func needsUIUpdate()
    func didGetNewOrder()
}

class OrdersViewModel {
    var viewKey: OrdersViewControllerViewKey = .orders
    var delegate: OrdersViewModelDelegate?
    let id = UUID().uuidString
    
    private var kitchenOrders: [KitchenOrder]? {
        didSet {
            delegate?.needsUIUpdate()
        }
    }
    
    private var sortedKitchenOrders: [KitchenOrder]? {
        // Result of sorting kitchen orders by date.
        return kitchenOrders?.sorted { $0.order.date.compare($1.order.date) == .orderedDescending }
    }
    
    var orderFoods: [Food]? {
        didSet {
            delegate?.needsUIUpdate()
        }
    }
    
    private var cellViewModels: [TableViewCellViewModel]? {
        switch viewKey {
        case .orders: return sortedKitchenOrders?.map { OrderTableViewCellViewModelFactory(kitchenOrder: $0).create() }
        case .foods: return orderFoods?.map { FoodTableViewCellViewModelFactory(food: $0).create() }
        }
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    init() {
        OrdersAPIClient.addObserver(self)
    }
    
    deinit {
        OrdersAPIClient.removeObserver(self)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return cellViewModels?.count ?? 0
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
        return cellViewModels?[indexPath.row]
    }
    
    func orderTitle(for indexPath: IndexPath) -> String? {
        return sortedKitchenOrders?[indexPath.row].order.userName
    }
    
    /// Use when showing orders to get the foods for the given order's index path.
    func foods(for indexPath: IndexPath) -> [Food]? {
        return sortedKitchenOrders?[indexPath.row].order.foods[.salad]
    }
    
    /// Use when showing foods to get the food at the given index path.
    func food(for indexPath: IndexPath) -> Food? {
        return orderFoods?[indexPath.row]
    }
}

extension OrdersViewModel: OrdersAPIObserver {
    func ordersValueDidChange(_ kitchenOrders: [KitchenOrder]) {
        if let currentKitchenOrders = self.kitchenOrders,
            kitchenOrders.count > currentKitchenOrders.count {
            delegate?.didGetNewOrder()
        }
        self.kitchenOrders = kitchenOrders
    }
}
