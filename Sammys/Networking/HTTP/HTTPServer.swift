//
//  HTTPServer.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HTTPServer {
    let scheme: Scheme
    let host: String
    let port: Int
    
    init(scheme: Scheme = .http,
         host: String,
         port: Int = 80) {
        self.scheme = scheme
        self.host = host
        self.port = port
    }
    
    enum Scheme: String {
        case http
        case https
    }
}
