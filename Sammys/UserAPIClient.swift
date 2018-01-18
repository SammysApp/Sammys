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
                let newUser = User(id: user.uid, email: email, name: "Natanel", photoURL: user.photoURL)
                self.database.child("users").child(user.uid).child("customerID").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let customerID = snapshot.value as? String {
                        print(customerID)
                        newUser.customerID = customerID
                        print(newUser)
                    }
                })
                UserDataStore.shared.user = newUser
                completed?()
            }
        }
    }
    
    static func set(_ favorites: [Salad], for user: User) {
        do {
            let jsonData = try JSONEncoder().encode(favorites)
            let jsonString = String(data: jsonData, encoding: .utf8)
            database.child("users").child(user.id).child("favorites").setValue(jsonString)
        } catch {
            
        }
    }
    
    static func set(_ customerID: String, for user: User) {
        database.child("users").child(user.id).child("customerID").setValue(customerID)
    }
}
