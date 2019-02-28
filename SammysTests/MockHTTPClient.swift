//
//  MockHTTPClient.swift
//  SammysTests
//
//  Created by Natanel Niazoff on 2/28/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
@testable import Sammys
import PromiseKit

struct MockHTTPClient: HTTPClient {
    let requestHandler: (URLRequest) -> HTTPResponse
    
    init(requestHandler: @escaping (URLRequest) -> HTTPResponse) {
        self.requestHandler = requestHandler
    }
    
    func send(_ request: URLRequest) -> Promise<HTTPResponse> {
        return Promise { $0.fulfill(requestHandler(request)) }
    }
}
