//
//  HTTPHeaderValue.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HTTPHeaderValue {
    case bearerAuthentication(String)
    case json
    
    var rawValue: String {
        switch self {
        case .bearerAuthentication(let token):
            return "Bearer \(token)"
        case .json:
            return "application/json"
        }
    }
}
