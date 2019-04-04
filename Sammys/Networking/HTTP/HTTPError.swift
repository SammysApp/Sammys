//
//  HTTPError.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HTTPError: Error, LocalizedError {
    case badStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .badStatusCode(let code): return "Bad status code: \(code)"
        }
    }
}
