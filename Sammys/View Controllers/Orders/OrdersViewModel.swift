//
//  OrdersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewModel {
//    let contextBounds: CGRect
//    
//    private var orders = [Order]()
//    
//    private var cellViewModels: [CollectionViewCellViewModel] {
//        return orders.map { OrderCollectionViewCellViewModelFactory(order: $0, size: CGSize(width: contextBounds.width - 20, height: 140)).create() }
//    }
//    
//    var user: User?
//    
//    var numberOfSections: Int {
//        return 1
//    }
//    
//    var numberOfRows: Int {
//        return orders.count
//    }
//    
//    init(contextBounds: CGRect) {
//        self.contextBounds = contextBounds
//    }
//    
//    func setData(completed: (() -> Void)? = nil) {
//        guard let user = user else { return }
////        UserAPIClient.fetchOrders(for: user) { result in
////            switch result {
////            case .success(let orders):
////                self.orders = orders
////                completed?()
////            case .failure(let error):
////                print(error.localizedDescription)
////                completed?()
////            }
////        }
//    }
//    
//    func cellViewModel(forRow row: Int) -> CollectionViewCellViewModel {
//        return cellViewModels[row]
//    }
//    
//    func orderViewController(for indexPath: IndexPath) -> OrderViewController {
//        let order = orders[indexPath.row]
//        let orderViewController = OrderViewController.storyboardInstance() as! OrderViewController
//        orderViewController.viewModel = OrderViewModel(order: order)
//        orderViewController.title = "Order #\(order.number)"
//        return orderViewController
//    }
}
