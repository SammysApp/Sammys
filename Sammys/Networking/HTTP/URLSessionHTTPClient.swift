//
//  URLSessionHTTPClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func send(_ request: URLRequest) -> Promise<HTTPResponse> {
        return session.dataTask(.promise, with: request).map(HTTPResponse.init)
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
