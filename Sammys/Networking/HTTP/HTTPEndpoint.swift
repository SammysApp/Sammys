//
//  HTTPEndpoint.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

typealias URLPath = String

protocol HTTPEndpoint {
    var endpoint: (HTTPMethod, URLPath) { get }
}
