//
//  DataAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum FoodAPIKey: String {
	case name, items
}

enum FoodAPIName: String {
	case salad
}

enum SaladAPIItems: String {
	case sizes, lettuces, vegetables, toppings, dressings, extras
}

struct DataAPIManager: APIManager {
    enum APIEndpoint: String, Endpoint {
		static let baseURL = "http://api.sammys.app"
        case hours, foods
    }
    
	static func getFoodItems<T: Decodable>(parameters: [String : Any], apiService: APIService = AlamofireAPIService()) -> Promise<T> {
        return get(.foods, parameters: parameters, apiService: apiService)
    }
}
