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

struct PaymentAPIManager: APIManager, APIParameterNameable {
    enum APIParameterName: String, Hashable {
        case isLive = "is_live"
        case customerID = "customer_id"
        case sourceID = "source_id"
        case tokenID = "token_id"
        case apiVersion = "api_version"
        case email, amount
    }
    
    enum APIEndpoint: String, Endpoint {
        static var baseURL = "https://sammysapp.herokuapp.com"
        case createCustomer = "create-customer"
        case chargeSource = "charge-source"
        case chargeCustomer = "charge-customer"
        case chargeCustomerSource = "charge-card" // Fix in server to: charge-customer-source
        case createEphemeralKey = "create-ephemeral-key"
    }
    
    private static var isLiveKey: String {
        return "\(environment.isLive)"
    }
    
    static func createCustomer(email: String, apiService: APIService = AlamofireAPIService()) -> Promise<Customer> {
        return post(.createCustomer,
                    parameters: [.isLive: isLiveKey, .email: email],
                    apiService: apiService)
    }
    
    static func chargeSource(id: String, amount: Int, apiService: APIService = AlamofireAPIService()) -> Promise<Void> {
        return post(.chargeSource,
                    parameters: [.isLive: isLiveKey, .sourceID: id, .amount: amount],
                    apiService: apiService)
    }
    
    
    static func chargeCustomer(id: String, amount: Int, apiService: APIService = AlamofireAPIService()) -> Promise<Void> {
        return post(.chargeCustomer,
                    parameters: [.isLive: isLiveKey, .customerID: id, .amount: amount],
                    apiService: apiService)
    }
    
    static func chargeCustomerSource(sourceID: String, customerID: String, amount: Int, apiService: APIService = AlamofireAPIService()) -> Promise<Void> {
        return post(.chargeCustomerSource,
                    parameters: [.isLive: isLiveKey, .sourceID: sourceID, .customerID: customerID, .amount: amount],
                    apiService: apiService)
    }
    
    static func createEphemeralKey(customerID: String, apiVersion: String, apiService: APIService = AlamofireAPIService()) -> Promise<JSON> {
        return post(.createEphemeralKey,
                    parameters: [.isLive: isLiveKey, .customerID: customerID, .apiVersion: apiVersion],
                    apiService: apiService)
    }
}
