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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(title, forKey: .price)
    }
    
    static func ==(lhs: Modifier, rhs: Modifier) -> Bool {
        return lhs.title == rhs.title
    }
}
