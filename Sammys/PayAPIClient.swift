//
//  PayAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

/// A type that represents a Stripe customer.
struct Customer: Decodable {
    let id: String
    let email: String
}

/// A client to make calls to the payment 💰 API 🏭.
struct PayAPIClient {
    typealias JSON = [String : Any]
    
    static let baseURL = "https://sammysapp.herokuapp.com"
    
    /**
     A type returned by the charge API call.
     - `success`: ended with success.
     - `error`
     */
    enum ChargeAPIResult {
        case success
        case failure(message: String)
    }
    
    /**
     A type returned by the create customer API call.
     - `success`: ended with success.
     - `error`
     */
    enum CreateCustomerAPIResult {
        case success(Customer)
        case failure(message: String)
    }
    
    /// A collection of parameter symbols to send the API.
    struct Symbols {
        static let email = "email"
        static let customerID = "customer_id"
        static let tokenID = "token_id"
        static let amount = "amount"
    }
    
    /**
     Charges the given customer ID for the given amount.
     - Parameter customerID: The customer ID to charge.
     - Parameter amount: The amount to charge the customer. Represented in cents.
     - Parameter completed: The closure to call upon completion.
     */
    static func charge(_ customerID: String, amount: Int, completed: ((ChargeAPIResult) -> Void)? = nil) {
        let params: Parameters = [Symbols.customerID: customerID, Symbols.amount: amount]
        Alamofire.request(baseURL.chargeCustomer, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            if response.result.value != nil {
                completed?(.success)
            } else if let error = response.error {
                completed?(.failure(message: error.localizedDescription))
            }
        }
    }
    
    /**
     Charges the a guest customer with the given token ID for the given amount.
     - Parameter tokenID: The token ID to charge.
     - Parameter amount: The amount to charge the customer. Represented in cents.
     - Parameter completed: The closure to call upon completion.
     */
    static func chargeGuest(_ tokenID: String, amount: Int, completed: ((ChargeAPIResult) -> Void)? = nil) {
        let params: Parameters = [Symbols.tokenID: tokenID, Symbols.amount: amount]
        Alamofire.request(baseURL.chargeGuestCustomer, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if response.result.value != nil {
                    completed?(.success)
                } else if let error = response.error {
                    completed?(.failure(message: error.localizedDescription))
                }
        }
    }
    
    /**
     Creates a new customer with the given token ID by the Stripe SDK.
     - Parameter tokenID: The token ID to associate with the customer.
     - Parameter email: The email to associate with the customer.
     - Parameter completed: The closure to call upon completion.
     */
    static func createNewCustomer(with tokenID: String, email: String, completed: ((CreateCustomerAPIResult) -> Void)? = nil) {
        let params: Parameters = [Symbols.tokenID: tokenID, Symbols.email: email]
        Alamofire.request(baseURL.newCustomer, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            if let jsonData = response.data {
                let decoder = JSONDecoder()
                if let customer = try? decoder.decode(Customer.self, from: jsonData) {
                    completed?(.success(customer))
                }
            } else if let error = response.error {
                completed?(.failure(message: error.localizedDescription))
            }
        }
    }
}

/// A collection of endpoints to append to the base url.
private extension String {
    var newCustomer: String {
        return self + "/create-customer"
    }
    
    var chargeCustomer: String {
        return self + "/charge-customer"
    }
    
    var chargeGuestCustomer: String {
        return self + "/charge-guest-customer"
    }
}

extension Double {
    /// Transfers a `Double` decimal dollar amount to cents as an `Int`.
    func toCents() -> Int {
        return Int(self * 100)
    }
}
