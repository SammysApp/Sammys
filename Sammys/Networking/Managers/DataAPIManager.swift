//
//  DataAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct DataAPIManager: APIManager {
    enum APIEndpoint: String, Endpoint {
        static let baseURL = "https://sammysapp.herokuapp.com"
        case hours, foods
    }
    
    static func getHours(apiService: APIService = AlamofireAPIService()) -> Promise<[Hours]> {
        return get(.hours, apiService: apiService)
    }
    
//    static func getFoods(apiService: APIService = AlamofireAPIService()) -> Promise<FoodsData> {
//        return get(.foods, apiService: apiService)
//    }
}
