//
//  User.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class User: CustomStringConvertible {
    var id: String
    var email: String
    var name: String
    var photoURL: URL?
    
    init(id: String, email: String, name: String, photoURL: URL?) {
        self.id = id
        self.email = email
        self.name = name
        self.photoURL = photoURL
    }
    
    var description: String {
        return "name: \(name), email: \(email)"
    }
}
