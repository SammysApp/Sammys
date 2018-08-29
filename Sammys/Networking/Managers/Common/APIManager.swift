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
    associatedtype APIParameterName: Hashable, RawRepresentable where APIParameterName.RawValue == String
    associatedtype APIEndpoint: Endpoint
}

extension APIManager {
    typealias APIParameters = [APIParameterName : Any]
    
    static func get<T: Decodable>(_ endpoint: APIEndpoint, apiService: APIService) -> Promise<T> {
        return apiService.get(endpoint)
    }
    
    static func post(_ endpoint: APIEndpoint, parameters: APIParameters = [:], apiService: APIService) -> Promise<Void> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
    
    static func post(_ endpoint: APIEndpoint, parameters: APIParameters = [:], apiService: APIService) -> Promise<JSON> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
    
    static func post<T: Decodable>(_ endpoint: APIEndpoint, parameters: APIParameters = [:],  apiService: APIService) -> Promise<T> {
        return apiService.post(endpoint, parameters: parameters.asAPIParameters())
    }
}
