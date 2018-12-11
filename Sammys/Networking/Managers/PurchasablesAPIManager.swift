//
//  PurchasablesAPIManager.swift
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

struct PurchasablesAPIManager: APIManager {
	enum APIEndpoint: Endpoint {
		static let baseURL = "http://api.sammys.app"
		case purchasables, categories
		case custom(String)
		case group([APIEndpoint])
    }
	
	func categories(apiService: APIService = AlamofireAPIService()) -> Promise<[PurchasableCategoryNode]> {
		return get(.group([.purchasables, .categories]), apiService: apiService)
	}
    
	func purchasables<P: Purchasable>(path: String, apiService: APIService = AlamofireAPIService()) -> Promise<[P]> {
        return get(.custom(path), apiService: apiService)
    }
	
	func items(path: String, apiService: APIService = AlamofireAPIService()) -> Promise<[Item]> {
		return get(.custom(path), apiService: apiService)
	}
}

extension PurchasablesAPIManager.APIEndpoint {
	var path: String {
		switch self {
		case .custom(let path): return path
		case .group(let paths): return paths.reduce("") { $0 + $1.path }
		default: return "/" + String(describing: self)
		}
	}
}
