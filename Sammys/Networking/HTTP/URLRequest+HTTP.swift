//
//  URLRequest+HTTP.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

extension URLRequest {
    init?(server: HTTPServer,
          endpoint: HTTPEndpoint,
          headers: [HTTPHeader] = []) {
        guard let url = URL(string: server.urlString + endpoint.endpoint.1)
            else { return nil }
        self.init(url: url)
        self.set(endpoint.endpoint.0)
        headers.forEach { self.add($0) }
    }
}

extension URLRequest {
    mutating func set(_ httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod.rawValue
    }
}

extension URLRequest {
    mutating func add(_ httpHeader: HTTPHeader) {
        self.addValue(httpHeader.value.rawValue,
                      forHTTPHeaderField: httpHeader.name.rawValue)
    }
}
