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
    static let baseURL = "http://localhost:4567" //"https://sammysapp.herokuapp.com"
    
    enum FoodsAPIResult {
        case success(FoodsData)
        case failure(Error)
    }
    
    static func getFoods(completed: @escaping ((_ result: FoodsAPIResult) -> Void)) {
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

/// A type representing all available foods.
struct FoodsData: Decodable {
    let salad: SaladData
    
    struct SaladData: Decodable {
        let sizes: [Size]
        let lettuce: [Lettuce]
        let vegetables: [Vegetable]
        let toppings: [Topping]
        let dressings: [Dressing]
        let extras: [Extra]
        
        var allItems: [SaladItemType : [Item]] {
            return [
                .size: sizes,
                .lettuce: lettuce,
                .vegetable: vegetables,
                .topping: toppings,
                .dressing: dressings,
                .extra: extras
            ]
        }
    }
}

private extension String {
    var foods: String {
        return self + "/foods"
    }
}
