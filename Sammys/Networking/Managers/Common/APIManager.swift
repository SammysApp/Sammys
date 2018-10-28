//
//  APIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 8/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

protocol APIManager {
    associatedtype APIEndpoint: Endpoint
}

protocol APIParameterNameable: APIManager {
    associatedtype APIParameterName: Hashable, RawRepresentable where APIParameterName.RawValue == String
}

extension APIManager {
    static func get<T: Decodable>(_ endpoint: APIEndpoint, parameters: Parameters = [:], apiService: APIService) -> Promise<T> {
		return apiService.get(endpoint, parameters: parameters)
    }
    
    static func post(_ endpoint: APIEndpoint, parameters: Parameters = [:], apiService: APIService) -> Promise<Void> {
        return apiService.post(endpoint, parameters: parameters)
    }
    
    static func post(_ endpoint: APIEndpoint, parameters: Parameters = [:], apiService: APIService) -> Promise<JSON> {
        return apiService.post(endpoint, parameters: parameters)
    }
    
    static func post<T: Decodable>(_ endpoint: APIEndpoint, parameters: Parameters = [:],  apiService: APIService) -> Promise<T> {
        return apiService.post(endpoint, parameters: parameters)
    }
}

extension APIParameterNameable {
    typealias APIParameters = [APIParameterName : Any]
    
    static func post(_ endpoint: APIEndpoint, parameters: APIParameters = [:], apiService: APIService) -> Promise<Void> {
        return post(endpoint, parameters: parameters.asAPIParameters(), apiService: apiService)
    }
    
    static func post(_ endpoint: APIEndpoint, parameters: APIParameters = [:], apiService: APIService) -> Promise<JSON> {
        return post(endpoint, parameters: parameters.asAPIParameters(), apiService: apiService)
    }
    
    static func post<T: Decodable>(_ endpoint: APIEndpoint, parameters: APIParameters = [:],  apiService: APIService) -> Promise<T> {
        return post(endpoint, parameters: parameters.asAPIParameters(), apiService: apiService)
    }
}
