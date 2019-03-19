//
//  User.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct User: Codable {
    typealias ID = UUID
    typealias UID = String
    
    let id: ID
    let uid: UID
    var email: String
    var firstName: String
    var lastName: String
}
