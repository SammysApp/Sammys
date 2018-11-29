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

enum OrdersAPIManagerError: Error { case noChildrenSnapshots }

typealias OrderNumber = Int

struct OrdersAPIManager: FirebaseAPIManager {
    enum Path: String, PathStringRepresentable {
        case orders, numberCounter
        case user
		case id
    }
    
    private func ordersDatabaseReference(_ path: Path...) -> DatabaseReference {
        return databaseReference(.orders).child(path)
    }
	
	private func ordersDatabaseQuery(for user: User) -> DatabaseQuery {
		return ordersDatabaseReference()
			.queryOrdered(byChild: .user, .id)
			.queryEqual(toValue: user.id)
	}
	
	func orders(for user: User) -> Promise<[Order]> {
		return Client.observeOnce(at: self.ordersDatabaseQuery(for: user))
			.map { snapshot in
				guard let ordersDataSnapshot = snapshot.allChildrenSnapshots
					else { throw OrdersAPIManagerError.noChildrenSnapshots }
				return try ordersDataSnapshot.map { try Client.decode($0) }
			}
	}
    
    func generateOrderNumber() -> Promise<OrderNumber> {
        return Client.incrementCounter(at: ordersDatabaseReference(.numberCounter))
    }
    
    func add(_ order: Order) throws {
        try Client.set(order, at: ordersDatabaseReference().child("\(order.id)"))
    }
}

private extension DatabaseQuery {
    func queryOrdered(byChild path: OrdersAPIManager.Path...) -> DatabaseQuery {
        return queryOrdered(byChild: path)
    }
}
