//
//  URLSession+HTTPClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

extension URLSession: HTTPClient {
    func send(_ request: URLRequest) -> Promise<HTTPResponse> {
        return self.dataTask(.promise, with: request).map(HTTPResponse.init)
    }
}

private extension HTTPResponse {
    init(data: Data, response: URLResponse) throws {
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw URLSessionHTTPClientError.notHTTPURLResponse
        }
        self.init(statusCode: httpURLResponse.statusCode, data: data)
    }
}

enum URLSessionHTTPClientError: Error {
    case notHTTPURLResponse
}
