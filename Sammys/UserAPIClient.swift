//
//  UserAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct UserAPIClient {
    private static let database = Database.database().reference()
    
    static func createUser(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
            } else if let user = user {
                self.database.child("users").child(user.uid).setValue("hello")
            }
        }
    }
    
    static func signIn(withEmail email: String, password: String, completed: (() -> Void)? = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
            } else if let user = user {
                guard let email = user.email else {
                    print("not good")
                    return
                }
                UserDataStore.shared.user = User(id: user.uid, email: email, name: "Natanel", photoURL: user.photoURL)
                print(UserDataStore.shared.user ?? "nothing")
                self.database.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                })
                completed?()
            }
        }
    }
}
