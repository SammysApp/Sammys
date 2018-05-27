//
//  DataAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

struct DataAPIClient {
    static let baseURL = "https://sammysapp.herokuapp.com"
    
    enum APIResult {
        case success(FoodsData)
        case failure(Error)
    }
    
    static func getFoods(completed: @escaping ((_ result: APIResult) -> Void)) {
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
}
