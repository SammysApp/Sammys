//
//  OrdersAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/15/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase

enum Path: String, PathStringRepresentable {
    case develop, live
    case orders, numberCounter
    case order, userID
    case kitchen, calendarDate, isInProgress, isCompleted
}

struct OrdersAPIManager {
    static let id = UUID().uuidString
    
    private typealias SnapshotPromise = Promise<DataSnapshot>
    typealias OrdersPromise = Promise<[KitchenOrder]>
    typealias OrdersObservable = Variable<Promise<[KitchenOrder]>>
    
    private static var ordersSnapshotObservable = observableSnapshot()
    private static var ordersSnapshotUpdate = UpdateClosure<SnapshotPromise>(id: id) { promise in
        ordersObservable.value = promise.map { decodeOrdersSnapshot($0) }
    }
    
    static let ordersObservable = OrdersObservable()
    
    static func beginObservingOrders() {
        ordersSnapshotObservable.add(ordersSnapshotUpdate)
    }
    
    private static func decodeOrdersSnapshot(_ snapshot: DataSnapshot) -> [KitchenOrder] {
        guard let ordersSnapshot = snapshot.allChildrenSnapshots else { fatalError() }
        return ordersSnapshot.compactMap { KitchenOrder(orderData: try? decode($0)) }
    }
}

private struct OrderData: Codable {
    let kitchen: KitchenData
    let order: Order
}

private struct KitchenData: Codable {
    let calendarDate: String
    let isInProgress: Bool
    let isCompleted: Bool
}

private extension KitchenOrder {
    /// Used when mapping snapshots to kitchenOrders. Will return nil if can't decode snapshot.
    init?(orderData: OrderData?) {
        guard let orderData = orderData else { return nil }
        self.init(order: orderData.order, isInProgress: orderData.kitchen.isInProgress, isCompleted: orderData.kitchen.isCompleted)
    }
}
