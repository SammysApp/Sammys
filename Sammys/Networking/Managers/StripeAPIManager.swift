//
//  StripeAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct StripeAPIManager: APIManager, APIParameterNameable {
    enum APIParameterName: String, Hashable {
        case isLive = "is_live"
        case customer, source, email, amount, version
    }
    
    enum APIEndpoint: String, Endpoint {
        static var baseURL = "http://api.sammys.app"
        case createCustomer = "create_customer"
		case createCharge = "create_charge"
        case createEphemeralKey = "create_ephemeral_key"
    }
    
    private var isLive: String { return "\(environment.isLive)" }
    
	private func createCustomer(_ parameters: APIParameters, apiService: APIService) -> Promise<StripeCustomer> {
        return post(.createCustomer, parameters: parameters, apiService: apiService)
    }
    
    private func createCharge(_ parameters: APIParameters, apiService: APIService) -> Promise<StripeCharge> {
        return post(.createCharge, parameters: parameters, apiService: apiService)
    }
	
	func createCustomer(email: String? = nil, sourceID: String? = nil, apiService: APIService = AlamofireAPIService()) -> Promise<StripeCustomer> {
		var parameters: APIParameters = [.isLive: isLive]
		parameters[.email] = email
		parameters[.source] = sourceID
		return createCustomer(parameters, apiService: apiService)
	}
	
	func createCharge(amount: Int, source: String?, customer: String? = nil, apiService: APIService = AlamofireAPIService()) -> Promise<StripeCharge> {
		var parameters: APIParameters = [.isLive: isLive, .amount: amount]
		parameters[.source] = source
		parameters[.customer] = customer
		return createCharge(parameters, apiService: apiService)
	}
    
    func createEphemeralKey(customer: String, version: String, apiService: APIService = AlamofireAPIService()) -> Promise<JSON> {
        return post(
			.createEphemeralKey,
			parameters: [.isLive: isLive, .customer: customer, .version: version],
			apiService: apiService
		)
    }
}
