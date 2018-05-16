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

struct OrdersAPIClient {
    /// The shared Firebase database reference.
    private static let database = Database.database().reference()
    
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
    
    static func add(_ order: Order, to date: Date, withNumber number: Int) {
        do {
            let jsonData = try JSONEncoder().encode(order)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            ordersReference(for: date).child("\(number)").setValue(jsonString)
        } catch {
            print(error)
        }
    }
}

private extension DatabaseReference {
    var orders: DatabaseReference {
        return child("orders")
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
