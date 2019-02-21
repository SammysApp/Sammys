//
//  HTTPResponse.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct HTTPResponse {
    let statusCode: Int
    let data: Data
}

extension Promise where T == HTTPResponse {
    func validate() -> Promise<T> {
        return map { response in
            switch response.statusCode {
            case 200..<300: return response
            case let code: throw HTTPError.badStatusCode(code)
            }
        }
    }
}
