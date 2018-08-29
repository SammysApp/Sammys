//
//  Request.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

typealias Parameters = [String : Any]

protocol Request {
    var endpoint: Endpoint { get }
    var method: Method { get }
    var parameters: Parameters { get }
}

struct BasicRequest: Request {
    let endpoint: Endpoint
    let method: Method
    let parameters: Parameters
}

struct DecodableRequest<T: Decodable>: Request {
    let endpoint: Endpoint
    let method: Method
    let parameters: Parameters
    let decodableType: T.Type
}

protocol APIParametersConvertible {
    func asAPIParameters() -> Parameters
}

extension Dictionary: APIParametersConvertible where Key: RawRepresentable, Key.RawValue == String, Value: Any {
    func asAPIParameters() -> Parameters {
        let sequence: [(Parameters.Key, Parameters.Value)] = map { ($0.rawValue, $1) }
        return Dictionary<Parameters.Key, Parameters.Value>(uniqueKeysWithValues: sequence)
    }
}
