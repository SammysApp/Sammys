//
//  APIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

typealias URLRepresentable = String
typealias APIParameters = [String : Any]
typealias JSON = [String : Any]

// MARK: - APIEndpoint
protocol APIEndpoint {
    static var baseURL: URLRepresentable { get }
    var fullURL: URLRepresentable { get }
}

extension APIEndpoint {
    var fullURL: URLRepresentable { return Self.baseURL }
}

extension RawRepresentable where Self: APIEndpoint, RawValue == String {
    var fullURL: URLRepresentable {
        return Self.baseURL + "/" + rawValue
    }
}

// MARK: - APIMethod
enum APIMethod: String {
    case get    = "GET"
    case post   = "POST"
}

// MARK: - APIRequest
protocol APIRequest {
    var endpoint: APIEndpoint { get }
    var method: APIMethod { get }
    var parameters: APIParameters { get }
}

struct BasicAPIRequest: APIRequest {
    let endpoint: APIEndpoint
    let method: APIMethod
    let parameters: APIParameters
}

struct DecodableAPIRequest<T: Decodable>: APIRequest {
    let endpoint: APIEndpoint
    let method: APIMethod
    let parameters: APIParameters
    let decodableType: T.Type
}

// MARK: - APIService
protocol APIService {
    func handle(_ request: APIRequest) -> Promise<Void>
    func handle<T>(_ request: APIRequest, decodingHandler: @escaping (Data) throws -> T) -> Promise<T>
    func handle<T: Decodable>(_ request: DecodableAPIRequest<T>) -> Promise<T>
}

enum APIServiceError: Error {
    case nonJSONCastable
}

extension APIService {
    // MARK: Void
    func get<E: APIEndpoint>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<Void> {
        return handle(BasicAPIRequest(endpoint: endpoint, method: .get, parameters: parameters))
    }
    
    func post<E: APIEndpoint>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<Void> {
        return handle(BasicAPIRequest(endpoint: endpoint, method: .post, parameters: parameters))
    }
    
    // MARK: JSON
    func get<E: APIEndpoint>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<JSON> {
        return handle(BasicAPIRequest(endpoint: endpoint, method: .get, parameters: parameters), decodingHandler: dataDecodingHandler)
    }
    
    func post<E: APIEndpoint>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<JSON> {
        return handle(BasicAPIRequest(endpoint: endpoint, method: .post, parameters: parameters), decodingHandler: dataDecodingHandler)
    }
    
    // MARK: Decodable
    func get<E: APIEndpoint, T: Decodable>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<T> {
        return handle(DecodableAPIRequest(endpoint: endpoint, method: .get, parameters: parameters, decodableType: T.self))
    }
    
    func post<E: APIEndpoint, T: Decodable>(_ endpoint: E, parameters: APIParameters = [:]) -> Promise<T> {
        return handle(DecodableAPIRequest(endpoint: endpoint, method: .post, parameters: parameters, decodableType: T.self))
    }
    
    private func dataDecodingHandler(_ data: Data) throws -> JSON {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = jsonObject as? JSON else { throw APIServiceError.nonJSONCastable }
        return json
    }
}

// MARK: Alamofire
enum AlamofireAPIServiceError: Error {}

struct AlamofireAPIService: APIService {
    func handle(_ request: APIRequest) -> Promise<Void> {
        return alamofireRequest(request).responseData().asVoid()
    }
    
    func handle<T>(_ request: APIRequest, decodingHandler: @escaping (Data) throws -> T) -> Promise<T> {
        return alamofireRequest(request)
        .responseData()
        .map { data, _ in try decodingHandler(data) }
    }
    
    func handle<T: Decodable>(_ request: DecodableAPIRequest<T>) -> Promise<T> {
        return alamofireRequest(request)
        .responseDecodable(request.decodableType)
    }
}

func alamofireRequest(_ request: APIRequest) -> DataRequest {
    guard let method = request.method.httpMethod else { fatalError() }
    return Alamofire.request(request.endpoint.fullURL,
                             method: method,
                             parameters: request.parameters).validate()
}

func alamofireRequest<T: Decodable>(_ request: DecodableAPIRequest<T>) -> DataRequest {
    guard let method = request.method.httpMethod else { fatalError() }
    return Alamofire.request(request.endpoint.fullURL,
                             method: method,
                             parameters: request.parameters).validate()
}

extension APIMethod {
    var httpMethod: HTTPMethod? {
        return HTTPMethod(rawValue: rawValue)
    }
}

// MARK - APIParametersConvertible
protocol APIParametersConvertible {
    func asAPIParameters() -> APIParameters
}

extension Dictionary: APIParametersConvertible where Key: RawRepresentable, Key.RawValue == String, Value: Any {
    func asAPIParameters() -> APIParameters {
        let sequence: [(APIParameters.Key, APIParameters.Value)] = map { ($0.rawValue, $1) }
        return Dictionary<APIParameters.Key, APIParameters.Value>(uniqueKeysWithValues: sequence)
    }
}
