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
	case type, category
}

struct DataAPIManager: APIManager {
    enum APIEndpoint: String, Endpoint {
		static let baseURL = "http://api.sammys.app"
        case purchasables
    }
    
	private func purchasables<T: Decodable>(parameters: [String : Any], apiService: APIService = AlamofireAPIService()) -> Promise<T> {
        return get(.purchasables, parameters: parameters, apiService: apiService)
    }
	
	func purchasables<T: Decodable>(for type: String, category: String?, apiService: APIService = AlamofireAPIService()) -> Promise<T> {
		var parameters = [PurchasableAPIKey.type.rawValue: type]
		parameters[PurchasableAPIKey.category.rawValue] = category
		return purchasables(parameters: parameters, apiService: apiService)
	}
}
