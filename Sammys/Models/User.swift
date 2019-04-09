//
//  User.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class User: Codable {
    typealias ID = UUID
    typealias UID = String
    
    let id: ID
    let uid: UID
    let email: String
    let firstName: String
    let lastName: String
}
