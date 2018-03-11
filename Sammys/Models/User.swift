//
//  User.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a user 👩🏻.
class User {
    /// A unique id.
    var id: String
    
    /// A user's email.
    var email: String
    
    /// A user's name.
    var name: String
    
    /// A `URL` for the user's photo.
    var photoURL: URL?
    
    /// A cache for a user's favorites.
    var favorites = [FavoriteGroup]()
    
    /**
     Initializes a new user with the given information.
     - Parameters:
        - id: The user's unique identification.
        - email: The user's email.
        - name: The user's name.
        - photoURL: The user's photo URL. Default value is `nil`.
     - Returns: A new user with the given information.
    */
    init(id: String, email: String, name: String, photoURL: URL? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.photoURL = photoURL
    }
}

// MARK: - CustomStringConvertible
extension User: CustomStringConvertible {
    var description: String {
        return "name: \(name), email: \(email)"
    }
}
// MARK: -
