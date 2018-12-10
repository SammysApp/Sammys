//
//  APIService.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

typealias JSON = [String : Any]

enum APIServiceError: Error {
    case nonJSONCastable
}

protocol APIService {
    func handle(_ request: Request) -> Promise<Void>
    func handle<T>(_ request: Request, decodingHandler: @escaping (Data) throws -> T) -> Promise<T>
	func handle<T: Decodable>(_ request: DecodableRequest<T>, decoder: JSONDecoder) -> Promise<T>
}

// MARK: - Void
extension APIService {
    func get<E: Endpoint>(_ endpoint: E, parameters: Parameters = [:]) -> Promise<Void> {
        return handle(BasicRequest(endpoint: endpoint, method: .get, parameters: parameters))
    }
    
    func post<E: Endpoint>(_ endpoint: E, parameters: Parameters = [:]) -> Promise<Void> {
        return handle(BasicRequest(endpoint: endpoint, method: .post, parameters: parameters))
    }
}

// MARK: - JSON
extension APIService {
    func get<E: Endpoint>(_ endpoint: E, parameters: Parameters = [:]) -> Promise<JSON> {
        return handle(BasicRequest(endpoint: endpoint, method: .get, parameters: parameters), decodingHandler: dataDecodingHandler)
    }
    
    func post<E: Endpoint>(_ endpoint: E, parameters: Parameters = [:]) -> Promise<JSON> {
        return handle(BasicRequest(endpoint: endpoint, method: .post, parameters: parameters), decodingHandler: dataDecodingHandler)
    }
    
    private func dataDecodingHandler(_ data: Data) throws -> JSON {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = jsonObject as? JSON else { throw APIServiceError.nonJSONCastable }
        return json
    }
}

// MARK: Decodable
extension APIService {
	func get<E: Endpoint, T: Decodable>(_ endpoint: E, parameters: Parameters = [:], decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
		return handle(DecodableRequest(endpoint: endpoint, method: .get, parameters: parameters, decodableType: T.self), decoder: decoder)
    }
    
    func post<E: Endpoint, T: Decodable>(_ endpoint: E, parameters: Parameters = [:], decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
		return handle(DecodableRequest(endpoint: endpoint, method: .post, parameters: parameters, decodableType: T.self), decoder: decoder)
    }
}
