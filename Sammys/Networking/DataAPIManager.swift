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

//---------------------OLD---------------------//
struct DataAPIClient {
    static let baseURL = "https://sammysapp.herokuapp.com"
    
    enum APIResult<T> {
        case success(T)
        case failure(Error)
    }
    
    static func getHours(completed: @escaping ((_ result: APIResult<[Hours]>) -> Void)) {
        Alamofire.request(baseURL.hours)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if let jsonData = response.data {
                    if let hoursData = try? JSONDecoder().decode([Hours].self, from: jsonData) {
                        completed(.success(hoursData))
                    }
                } else if let error = response.error {
                    completed(.failure(error))
                }
        }
    }
    
    static func getFoods(completed: @escaping ((_ result: APIResult<FoodsData>) -> Void)) {
        Alamofire.request(baseURL.foods)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            if let jsonData = response.data {
                if let foodsData = try? JSONDecoder().decode(FoodsData.self, from: jsonData) {
                    completed(.success(foodsData))
                }
            } else if let error = response.error {
                completed(.failure(error))
            }
        }
    }
}

private extension String {
    var foods: String {
        return self + "/foods"
    }
    
    var hours: String {
        return self + "/hours"
    }
}
