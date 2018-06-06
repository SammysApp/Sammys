//
//  Modifier.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Modifier: Codable, Equatable {
    let title: String
    let price: Double?
    
    enum CodingKeys: String, CodingKey {
        case title, price
    }
    
    static func ==(lhs: Modifier, rhs: Modifier) -> Bool {
        return lhs.title == rhs.title
    }
}

extension Array where Element == Modifier {
    /// Returns a string consisting of the `name`s of `Modifier`s seperated by commas.
    var commaString: String? {
        return count > 1 ? map { $0.title }.joined(separator: ", ") : first?.title
    }
}
