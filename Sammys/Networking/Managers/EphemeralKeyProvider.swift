//
//  EphemeralKeyProvider.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

class EphemeralKeyProvider: NSObject, STPEphemeralKeyProvider {
    static let shared = EphemeralKeyProvider()
    
    enum EphemeralKeyError: Error {
        case noUser
    }
    
    private override init() {}
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        guard let user = UserDataStore.shared.user else { completion(nil, EphemeralKeyError.noUser); return }
        UserAPIManager.getCustomerID(for: user)
        .then { PaymentAPIManager.createEphemeralKey(customerID: $0, apiVersion: apiVersion) }
        .get { completion($0, nil) }
        .catch { completion(nil, $0) }
    }
}
