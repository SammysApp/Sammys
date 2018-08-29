//
//  Endpoint.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

typealias URLRepresentable = String

protocol Endpoint {
    static var baseURL: URLRepresentable { get }
    var fullURL: URLRepresentable { get }
}

extension Endpoint {
    var fullURL: URLRepresentable { return Self.baseURL }
}

extension RawRepresentable where Self: Endpoint, RawValue == String {
    var fullURL: URLRepresentable {
        return Self.baseURL + "/" + rawValue
    }
}
