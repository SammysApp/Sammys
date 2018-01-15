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
    
    static func createNewCustomer(with tokenID: String) {
        let params: [String : Any] = ["token": tokenID, "email": UserDataStore.shared.user!.email]
        Alamofire.request(baseURL + Endpoints.newCustomer, method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                print(json)
            } else {
                print(response.error.debugDescription)
            }
        }
    }
}
