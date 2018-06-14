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

protocol OrdersViewModelDelegate: class {
    func updateUI()
    func didGetNewOrder()
}

class OrdersViewModel {
    var viewKey: OrdersViewControllerViewKey = .orders
    weak var delegate: OrdersViewModelDelegate?
    let id = UUID().uuidString
    
    private var kitchenOrders: [KitchenOrder]? {
        didSet {
            delegate?.updateUI()
        }
    }
    
    private var sortedKitchenOrders: [KitchenOrder]? {
        // Result of sorting kitchen orders by date.
        return kitchenOrders?.sorted { $0.order.date.compare($1.order.date) == .orderedDescending }
    }
    
    var orderFoods: [Food]? {
        didSet {
            delegate?.updateUI()
        }
    }
    
    private var setTitle: String?
    
    var title: String? {
        get {
            let title: String
            switch UserDataStore.shared.observingDate {
            case .current: title = "Today"
            case .another(let date):
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                title = formatter.string(from: date)
            }
            return setTitle ?? title
        } set {
            setTitle = newValue
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
    
    var dateButtonShouldHide: Bool {
        return viewKey == .foods
    }
    
    var datePickerDate: Date {
        return UserDataStore.shared.currentDateObserving
    }
    
    var datePickerMinDate: Date {
        return Date().addingTimeInterval(-Constants.week)
    }
    
    var datePickerMaxDate: Date {
        return Date().addingTimeInterval(Constants.week)
    }
    
    var todayButtonShouldHide: Bool {
        return isObservingToday
    }
    
    var nothingLabelText: String {
        return isObservingToday ? "Nothing\nYet" : "Nothing\nHere"
    }
    
    var isOrdersEmpty: Bool {
        return kitchenOrders?.isEmpty ?? true
    }
    
    var isObservingToday: Bool {
        return UserDataStore.shared.observingDate == .current
    }
    
    var lastObservingDate = UserDataStore.shared.observingDate
    
    private struct Constants {
        static let week: TimeInterval = 7 * 24 * 60 * 60
    }
    
    func handleViewDidAppear() {
        OrdersAPIClient.addObserver(self)
    }
    
    func handleViewDidDisappear() {
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
    
    func isDateCurrent(_ date: Date) -> Bool {
        let dateComponents: Set<Calendar.Component> = [.day, .month]
        return Calendar.current.dateComponents(dateComponents, from: date) == Calendar.current.dateComponents(dateComponents, from: Date())
    }
    
    func handleDatePickerValueChange(_ date: Date) {
        UserDataStore.shared.observingDate = isDateCurrent(date) ? .current : .another(date)
    }
}

extension OrdersViewModel: OrdersAPIObserver {
    func ordersValueDidChange(_ kitchenOrders: [KitchenOrder]) {
        if let currentKitchenOrders = self.kitchenOrders,
            kitchenOrders.count > currentKitchenOrders.count,
            isObservingToday && lastObservingDate == .current {
            delegate?.didGetNewOrder()
        }
        self.kitchenOrders = kitchenOrders
        lastObservingDate = UserDataStore.shared.observingDate
    }
}
