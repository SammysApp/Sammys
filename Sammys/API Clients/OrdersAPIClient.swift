//
//  OrdersAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/15/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol OrdersAPIObserver {
    /// A unique id to identify the specific observer. Primarily used to remove the observer from observing.
    var id: String { get }
    
    func ordersValueDidChange(_ kitchenOrders: [KitchenOrder])
}

/// A singleton class that stores observers to `OrdersAPIClient`.
private class OrdersAPIObservers {
    /// The shared singleton property.
    static let shared = OrdersAPIObservers()
    
    /// The array of observers.
    var observers = [OrdersAPIObserver]()
    
    private init() {}
}

struct OrdersAPIClient {
    /// The shared Firebase database reference.
    private static var database: DatabaseReference {
        let reference =  Database.database().reference()
        return environment.isLive ? reference : reference.developer
    }
    
    // MARK: - Observers
    private static var observers: [OrdersAPIObserver] {
        get {
            return OrdersAPIObservers.shared.observers
        } set {
            OrdersAPIObservers.shared.observers = newValue
        }
    }
    
    fileprivate struct Paths {
        static let order = "order"
        static let completed = "completed"
    }
    
    enum APIResult<T> {
        case success(T)
        case failure(Error)
    }
    
    static func addObserver(_ observer: OrdersAPIObserver) {
        observers.append(observer)
    }
    
    static func removeObserver(_ observer: OrdersAPIObserver) {
        // Filter observer array to disclude the given observer by its unique id.
        observers = observers.filter { $0.id != observer.id }
    }
    
    private static func ordersReference(for date: Date) -> DatabaseReference {
        return database.orders.child(date)
    }
    
    static func fetchNewOrderNumber(for date: Date, completed: @escaping (Int) -> Void) {
        ordersReference(for: date).numberCounter.runTransactionBlock({ currentData in
            // If the counter doesn't exist...
            guard let value = currentData.value as? Int else {
                // ...set the counter to 1.
                currentData.value = 1
                return TransactionResult.success(withValue: currentData)
            }
            // Otherwise increment the value by 1.
            currentData.value = value + 1
            return TransactionResult.success(withValue: currentData)
        }) { error, commited, snapshot in
            if commited {
                guard let count = snapshot?.value as? Int else { return }
                completed(count)
            }
        }
    }
    
    static func startOrdersValueChangeObserver(for date: Date) {
        ordersReference(for: date).orders.observe(.value) { snapshot in
            guard snapshot.exists() else { return }
            var kitchenOrders = [KitchenOrder]()
            for orderSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                guard let orderJSONString = orderSnapshot.childSnapshot(forPath: Paths.order).value as? String,
                    let orderJSONData = orderJSONString.data(using: .utf8),
                    let completed = orderSnapshot.childSnapshot(forPath: Paths.completed).value as? Bool else { continue }
                do {
                    let order = try JSONDecoder().decode(Order.self, from: orderJSONData)
                    kitchenOrders.append(KitchenOrder(order: order, completed: completed))
                } catch {
                    print(error)
                }
            }
            observers.forEach { $0.ordersValueDidChange(kitchenOrders) }
        }
    }
    
    static func removeAllOrdersObservers(for date: Date) {
        ordersReference(for: date).orders.removeAllObservers()
    }
    
    static func add(_ order: Order, to date: Date, withNumber number: Int) {
        do {
            let jsonData = try JSONEncoder().encode(order)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            ordersReference(for: date).orders.child("\(number)").order.setValue(jsonString)
            setCompleted(false, for: order)
        } catch {
            print(error)
        }
    }
    
    static func setCompleted(_ completed: Bool, for order: Order) {
        ordersReference(for: order.date).orders.child("\(order.number)").completed.setValue(completed)
    }
}

private extension DatabaseReference {
    var developer: DatabaseReference {
        return child("developer")
    }
    
    var orders: DatabaseReference {
        return child("orders")
    }
    
    var order: DatabaseReference {
        return child("order")
    }
    
    var completed: DatabaseReference {
        return child("completed")
    }
    
    var numberCounter: DatabaseReference {
        return child("numberCounter")
    }
    
    func child(_ date: Date) -> DatabaseReference {
        guard let timeZone = TimeZone(identifier: "America/New_York") else { fatalError() }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return child("\(year)/\(month)/\(day)")
    }
}
