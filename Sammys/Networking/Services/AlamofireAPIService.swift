//
//  AlamofireAPIService.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum AlamofireAPIServiceError: Error {}

struct AlamofireAPIService: APIService {
    func handle(_ request: Request) -> Promise<Void> {
        return alamofireRequest(request).responseData().asVoid()
    }
    
    func handle<T>(_ request: Request, decodingHandler: @escaping (Data) throws -> T) -> Promise<T> {
        return alamofireRequest(request)
        .responseData()
        .map { data, _ in try decodingHandler(data) }
    }
    
	func handle<T: Decodable>(_ request: DecodableRequest<T>, decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
        return alamofireRequest(request)
        .responseDecodable(request.decodableType, decoder: decoder)
    }
    
    private func alamofireRequest(_ request: Request) -> DataRequest {
        guard let method = request.method.httpMethod else { fatalError() }
        return Alamofire.request(request.endpoint.fullURL,
                                 method: method,
                                 parameters: request.parameters).validate()
    }
}
