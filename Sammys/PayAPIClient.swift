//
//  PayAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

struct PayAPIClient {
    static let baseURL = "http://localHost:4567"
    
    struct Endpoints {
        static let newCustomer = "/create_customer"
        static let newCustomerCharge = "/charge_new_user_with_token_id"
        static let existingCustomerCharge = "/charge_existing_user_with_customer_id"
    }
    
    static func chargeNewUser(with tokenID: String, amount: Int) {
        let params: [String : Any] = ["token": tokenID, "amount": amount, "email": UserDataStore.shared.user!.email]
        Alamofire.request(baseURL + Endpoints.newCustomerCharge, method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                print(json)
            } else {
                print(response.error.debugDescription)
            }
        }
    }
    
    static func charge(_ customer: String, amount: Int) {
        let params: [String : Any] = ["customer": customer, "amount": amount, "email": UserDataStore.shared.user!.email]
        Alamofire.request(baseURL + Endpoints.existingCustomerCharge, method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                print(json)
            } else {
                print(response.error.debugDescription)
            }
        }
    }
    
    static func createNewCustomer(with tokenID: String) {
        let params: [String : Any] = ["token": tokenID, "email": UserDataStore.shared.user!.email]
        Alamofire.request(baseURL + Endpoints.newCustomer, method: .post, parameters: params).responseJSON { response in
            if let value = response.result.value {
                if let json = value as? [String : Any] {
                    if let id = json["id"] as? String {
                        UserDataStore.shared.user?.customerID = id
                    }
                }
            } else {
                print(response.error.debugDescription)
            }
        }
    }
}

extension Double {
    func toCents() -> Int {
        return Int(self * 100)
    }
}
