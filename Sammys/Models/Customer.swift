//
//  Customer.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A Stripe customer.
struct Customer: Decodable {
    let id: String
    let email: String
}
