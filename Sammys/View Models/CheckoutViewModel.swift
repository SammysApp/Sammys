//
//  CheckoutViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class CheckoutViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil`.
    var outstandingOrderID: OutstandingOrder.ID?
    /// Required to be non-`nil`.
    var userID: User.ID?
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    func beginCreatePurchasedOrderDownload(cardNonce: String, completionHandler: @escaping (Result<PurchasedOrder.ID>) -> Void) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.createPurchasedOrder(data: .init(outstandingOrderID: self.outstandingOrderID ?? preconditionFailure(), cardNonce: cardNonce, customerCardID: nil), token: $0) }
            .done { completionHandler(.fulfilled($0.id)) }
            .catch { completionHandler(.rejected($0)) }
    }
    
    private func createPurchasedOrder(data: CreateUserPurchasedOrderData, token: JWT) -> Promise<PurchasedOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserPurchasedOrdersRequest(id: userID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try JSONDecoder().decode(PurchasedOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
}
