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
    var favorites: [Salad] = [] {
        didSet {
            saveFavorites()
        }
    }
    var customerID: String? {
        didSet {
            saveCustomerID()
        }
    }
    
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

extension User {
    private func saveFavorites() {
        UserAPIClient.set(favorites, for: self)
    }
    
    private func saveCustomerID() {
        if let id = customerID {
            UserAPIClient.set(id, for: self)
        }
    }
}
