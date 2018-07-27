//
//  DataAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum DataAPIEndpoint: String, APIEndpoint {
    static let baseURL = "https://sammysapp.herokuapp.com"
    case hours, foods
}

struct DataAPIManager {
    static func getHours() -> Promise<[Hours]> { return get(.hours) }
    static func getFoods() -> Promise<FoodsData> { return get(.foods) }
}

extension DataAPIManager {
    static func get<T: Decodable>(_ endpoint: DataAPIEndpoint, _ apiService: APIService = AlamofireAPIService()) -> Promise<T> {
        return apiService.get(endpoint)
    }
}
