//
//  Offer.swift
//  Sammys
//
//  Created by Natanel Niazoff on 8/1/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class Offer: Codable {
    typealias ID = UUID
    typealias Code = String
    
    let id: ID
    let code: Code
    let name: String
}
