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
    var favorites: [Salad]?
    var customerID: String? {
        didSet {
            if customerID != nil {
                saveCustomerID()
            }
        }
    }
    
    init(id: String, email: String, name: String, photoURL: URL? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.photoURL = photoURL
    }
    
    var description: String {
        return "name: \(name), email: \(email)" + (customerID != nil ? ", customerID: \(customerID!)" : "")
    }
}

extension User {
    private func saveFavorites() {
//        if let favorites = favorites {
//            UserAPIClient.set(favorites, for: self)
//        }
    }
    
    private func saveCustomerID() {
        UserAPIClient.set(customerID!, for: self)
    }
}
