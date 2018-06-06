//
//  OrdersReadDataStore.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class OrdersReadDataStore {
    static let shared = OrdersReadDataStore()
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
    
    private init() {}
    
    func setRead(_ kitchenOrder: KitchenOrder) {
        readOrders.append(kitchenOrder.order.id)
    }
    
    func isRead(_ kitchenOrder: KitchenOrder) -> Bool {
        return readOrders.contains(kitchenOrder.order.id)
    }
}
