//
//  HTTPClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

protocol HTTPClient {
    func send(_ request: URLRequest) throws -> Promise<HTTPResponse>
}

extension HTTPClient {
    func send(_ endpoint: HTTPEndpoint, to server: HTTPServer, headers: [HTTPHeader] = [], data: Data? = nil) throws -> Promise<HTTPResponse> {
        guard var request = URLRequest(server: server, endpoint: endpoint, headers: headers) else { fatalError("Can't create `URLRequest` from parameters.") }
        request.httpBody = data
        return try send(request)
    }
}
