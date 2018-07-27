//
//  PaymentAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import Stripe

typealias PaymentAPIParameters = [PaymentParameterName : Any]

enum PaymentAPIEndpoint: String, APIEndpoint {
    static var baseURL = "https://sammysapp.herokuapp.com"
    case createCustomer = "create-customer"
    case chargeSource = "charge-source"
    case chargeCustomer = "charge-customer"
    case chargeCustomerSource = "charge-card" // Fix in server to: charge-customer-source
    case createEphemeralKey = "create-ephemeral-key"
}

enum PaymentParameterName: String, Hashable {
    case isLive = "is_live"
    case customerID = "customer_id"
    case sourceID = "source_id"
    case tokenID = "token_id"
    case apiVersion = "api_version"
    case email, amount
}

struct PaymentAPIManager {
    private static var isLiveKey: String {
        return "\(environment.isLive)"
    }
    
    static func createCustomer(email: String) -> Promise<Customer> {
        return post(.createCustomer,
                    parameters: [.isLive: isLiveKey, .email: email])
    }
    
    static func chargeSource(id: String, amount: Int) -> Promise<Void> {
        return post(.chargeSource,
                    parameters: [.isLive: isLiveKey, .sourceID: id, .amount: amount])
    }
    
    
    static func chargeCustomer(id: String, amount: Int) -> Promise<Void> {
        return post(.chargeCustomer,
                    parameters: [.isLive: isLiveKey, .customerID: id, .amount: amount])
    }
    
    static func chargeCustomerSource(sourceID: String, customerID: String, amount: Int) -> Promise<Void> {
        return post(.chargeCustomerSource,
                    parameters: [.isLive: isLiveKey, .sourceID: sourceID, .customerID: customerID, .amount: amount])
    }
    
    static func createEphemeralKey(customerID: String, apiVersion: String) -> Promise<JSON> {
        return post(.createEphemeralKey,
                    parameters: [.isLive: isLiveKey, .customerID: customerID, .apiVersion: apiVersion])
    }
}

extension PaymentAPIManager {
    static func post(_ endpoint: PaymentAPIEndpoint, parameters: PaymentAPIParameters = [:], _ apiService: APIService = AlamofireAPIService()) -> Promise<Void> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
    
    static func post(_ endpoint: PaymentAPIEndpoint, parameters: PaymentAPIParameters = [:], _ apiService: APIService = AlamofireAPIService()) -> Promise<JSON> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
    
    static func post<T: Decodable>(_ endpoint: PaymentAPIEndpoint, parameters: PaymentAPIParameters = [:], _ apiService: APIService = AlamofireAPIService()) -> Promise<T> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
}
