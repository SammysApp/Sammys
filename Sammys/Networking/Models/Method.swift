//
//  Method.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

enum Method: String {
    case get    = "GET"
    case post   = "POST"
}

extension Method {
    var httpMethod: HTTPMethod? {
        return HTTPMethod(rawValue: rawValue)
    }
}
