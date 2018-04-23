//
//  OrdersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewModel {
    var orders = [Order]()
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return orders.count
    }
    
    func setData(completed: (() -> Void)? = nil) {
        guard let user = user else { return }
        UserAPIClient.fetchOrders(for: user) { result in
            switch result {
            case .success(let orders):
                self.orders = orders
                completed?()
            case .failure(let error):
                print(error.localizedDescription)
                completed?()
            }
        }
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CollectionViewCellViewModel] {
        return orders.map { OrderCollectionViewCellViewModelFactory(order: $0, size: CGSize(width: contextBounds.width - 20, height: 100)).create() }
    }
}
