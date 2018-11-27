//
//  DataAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum PurchasableAPIKey: String {
	case type, items
}

enum PurchasableAPIType: String {
	case salad
}

enum SaladAPIItems: String {
	case sizes, lettuces, vegetables, toppings, dressings, extras
}

struct DataAPIManager: APIManager {
    enum APIEndpoint: String, Endpoint {
		static let baseURL = "http://api.sammys.app"
        case purchasables
    }
    
	private func getPurchasables<T: Decodable>(parameters: [String : Any], apiService: APIService = AlamofireAPIService()) -> Promise<T> {
        return get(.purchasables, parameters: parameters, apiService: apiService)
    }
	
	func getPurchasableItems<T: Decodable>(for type: PurchasableAPIType, items: String, apiService: APIService = AlamofireAPIService()) -> Promise<T> {
		return getPurchasables(
			parameters: [PurchasableAPIKey.type.rawValue: type, PurchasableAPIKey.items.rawValue: items],
			apiService: apiService
		)
	}
}
