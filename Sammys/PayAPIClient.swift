//
//  PayAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

/// A client to make calls to the payment API 🏭.
struct PayAPIClient {
    static let baseURL = "https://sammysapp.herokuapp.com"
    
    struct Symbols {
        static let email = "email"
        static let customerID = "customer_id"
        static let tokenID = "token_id"
        static let amount = "amount"
    }
    
    /**
     Charges the given customer ID for a given amount.
     - Parameter customer: The customer ID to charge.
     - Parameter amount: The amount to charge the customer. Represented in cents.
     */
    static func charge(_ customerID: String, amount: Int) {
        let params: Parameters = [Symbols.customerID: customerID, Symbols.amount: amount, Symbols.email: UserDataStore.shared.user!.email]
        Alamofire.request(baseURL.chargeCustomer, method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                print(json)
            } else {
                print(response.error.debugDescription)
            }
        }
    }
    
    static func createNewCustomer(with tokenID: String) {
        let params: Parameters = [Symbols.tokenID: tokenID, Symbols.email: UserDataStore.shared.user!.email]
        Alamofire.request(baseURL.newCustomer, method: .post, parameters: params).responseJSON { response in
            if let value = response.result.value {
                if let json = value as? [String : Any] {
                    if let id = json["id"] as? String {
                        UserDataStore.shared.user?.customerID = id
                        print(id)
                    }
                }
            } else {
                print(response.error.debugDescription)
            }
        }
    }
}

private extension String {
    var newCustomer: String {
        return self + "/create-customer"
    }
    
    var chargeCustomer: String {
        return self + "/charge-customer"
    }
}

extension Double {
    func toCents() -> Int {
        return Int(self * 100)
    }
}
