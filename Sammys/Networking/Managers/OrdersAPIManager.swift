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

typealias OrderNumber = Int

struct OrdersAPIManager: FirebaseAPIManager {
    enum Path: String, PathStringRepresentable {
        case orders, numberCounter
        case order, userID
        case kitchen, calendarDate
    }
    
    private func ordersDatabaseReference(_ path: Path...) -> DatabaseReference {
        return databaseReference(.orders).child(path)
    }
    
    private func ordersDatabaseQueryEqual(to date: Date) -> DatabaseQuery {
        return ordersDatabaseReference()
            .queryOrdered(byChild: .kitchen, .calendarDate)
            .queryEqual(toValue: calendarDateString(for: date))
    }
    
    private var calendarDateFormatter: DateFormatter {
        return DateFormatter(format: "M/d/yyyy")
    }
    
    private func decodeOrdersSnapshot(_ snapshot: DataSnapshot) throws -> [KitchenOrder] {
        guard let ordersSnapshot = snapshot.allChildrenSnapshots else { fatalError() }
        return try ordersSnapshot.map { KitchenOrder(orderData: try Client.decode($0)) }
    }
    
    func generateOrderNumber() -> Promise<OrderNumber> {
        return Client.incrementCounter(at: ordersDatabaseReference(.numberCounter))
    }
    
    private func calendarDateString(for date: Date) -> String {
        return calendarDateFormatter.string(from: date)
    }
    
    private func calendarDate(for order: Order) -> Date {
        return order.pickupDate ?? order.date
    }
    
    func add(_ order: Order) throws {
        let calendarDateString = self.calendarDateString(for: calendarDate(for: order))
		try Client.set(
			OrderData(kitchen: KitchenData(calendarDate: calendarDateString), order: order),
			at: ordersDatabaseReference().child("\(order.number)")
		)
    }
}

private struct OrderData: Codable {
    let kitchen: KitchenData
    let order: Order
}

private struct KitchenData: Codable {
    let calendarDate: String
    let isInProgress: Bool
    let isComplete: Bool
    
    init(calendarDate: String,
         isInProgress: Bool = false,
         isComplete: Bool = false) {
        self.calendarDate = calendarDate
        self.isInProgress = false
        self.isComplete = false
    }
}

private extension KitchenOrder {
    init(orderData: OrderData) {
        self.init(order: orderData.order, isInProgress: orderData.kitchen.isInProgress, isComplete: orderData.kitchen.isComplete)
    }
}

private extension DatabaseQuery {
    func queryOrdered(byChild path: OrdersAPIManager.Path...) -> DatabaseQuery {
        return queryOrdered(byChild: path)
    }
}
