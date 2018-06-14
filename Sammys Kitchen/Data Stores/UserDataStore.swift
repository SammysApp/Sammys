//
//  UserDataStore.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum ObservingDate: Equatable {
    case current
    case another(Date)
}

class UserDataStore {
    static let shared = UserDataStore()
    
    var observingDate: ObservingDate {
        didSet {
            switch observingDate {
            case .current: currentDateObserving = Date()
            case .another(let date): currentDateObserving = date
            }
            handleNewObservingDate()
        }
    }
    
    /// The current date being observed based on when the `observingDate` property was set.
    private(set) var currentDateObserving = Date()
    
    private var dateToObserve: Date {
        switch observingDate {
        case .current: return Date()
        case .another(let date): return date
        }
    }
    
    private var readOrders: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.readOrdersKey)
        } get {
            return (UserDefaults.standard.array(forKey: Constants.readOrdersKey) as? [String]) ?? []
        }
    }
    
    private struct Constants {
        static var readOrdersKey = "readOrders"
    }
    
    private init() {
        observingDate = .current
    }
    
    func startObservingDate() {
        startOrdersValueChangeObserver(for: dateToObserve)
    }
    
    func setRead(_ kitchenOrder: KitchenOrder) {
        readOrders.append(kitchenOrder.order.id)
    }
    
    func isRead(_ kitchenOrder: KitchenOrder) -> Bool {
        return readOrders.contains(kitchenOrder.order.id)
    }
    
    private func handleNewObservingDate() {
        removeAllOrdersObservers(for: currentDateObserving)
        startOrdersValueChangeObserver(for: dateToObserve)
    }
    
    func handleSignificantTimeChange() {
        if observingDate == .current {
            handleNewObservingDate()
        }
    }
    
    /// Starts observing for orders for the current date.
    private func startOrdersValueChangeObserver(for date: Date) {
        OrdersAPIClient.startOrdersValueChangeObserver(for: date)
    }
    
    private func removeAllOrdersObservers(for date: Date) {
        OrdersAPIClient.removeAllOrdersObservers(for: date)
    }
}
