//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class BagViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    
    // MARK: - View Settable Properties
    /// The bag's outstanding order's ID.
    /// Calling `beginDownloads()` will first attempt to get one if not set.
    var outstandingOrderID: OutstandingOrder.ID?
    
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isOutstandingOrderDownloading = Dynamic(false)
    let isItemsDownloading = Dynamic(false)
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
    }
    
    // MARK: - Download Method
    func beginDownloads() {
        if outstandingOrderID == nil {
            if let idString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.outstandingOrder),
                let id = OutstandingOrder.ID(uuidString: idString) {
                outstandingOrderID = id
                beginOutstandingOrderDownload()
            } else { errorHandler?(BagViewModelError.noOutstandingOrders); return }
        } else {
            beginOutstandingOrderDownload()
        }
    }
    
    private func beginOutstandingOrderDownload() {
        getOutstandingOrder().done { outstandingOrder in
            
        }.catch { self.errorHandler?($0) }
    }
    
    private func getOutstandingOrder() -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderRequest(id: outstandingOrderID ?? preconditionFailure()))
            .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
    }
}

enum BagViewModelError: Error {
    case noOutstandingOrders
}
