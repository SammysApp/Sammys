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
    func send(_ request: URLRequest) -> Promise<HTTPResponse>
}
