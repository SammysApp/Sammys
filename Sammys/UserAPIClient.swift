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

typealias FirebaseUser = Firebase.User

enum APIResult {
    case success
}

enum UserState {
    case noUser
    case currentUser(User)
}

protocol UserAPIObserver {
    var id: String { get }
    var handleUserStateChange: ((UserState) -> Void) { get }
}

private class UserAPIObservers {
    static let shared = UserAPIObservers()
    var observers = [UserAPIObserver]()
    
    private init() {}
}

struct UserAPIClient {
    private static let database = Database.database().reference()
    private static var observers: [UserAPIObserver] {
        get {
            return UserAPIObservers.shared.observers
        } set {
            UserAPIObservers.shared.observers = newValue
        }
    }
    
    static func addObserver(_ observer: UserAPIObserver) {
        observers.append(observer)
    }
    
    static func removeObserver(_ observer: UserAPIObserver) {
        observers = observers.filter { $0.id != observer.id }
    }
    
    static func startStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                setupCurrentUser(user)
            } else {
                observers.forEach { $0.handleUserStateChange(.noUser) }
            }
        }
    }
    
    static func setupCurrentUser(_ user: FirebaseUser) {
        guard let email = user.email, let name = user.displayName
            else { return }
        let currentUser = User(id: user.uid, email: email, name: name)
        observers.forEach { $0.handleUserStateChange(.currentUser(currentUser)) }
    }
    
    static func createUser(withEmail email: String, password: String, completionHandler: ((APIResult) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
            } else if let user = user {
//                database.child("users").child(user.uid).setValue("")
                setupCurrentUser(user)
                completionHandler?(.success)
            }
        }
    }
    
    static func signIn(withEmail email: String, password: String, completionHandler: (() -> Void)? = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            completionHandler?()
        }
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    static func updateUser(withName name: String, completionHandler: ((APIResult) -> Void)? = nil) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let error = error {
                print(error)
            } else {
                completionHandler?(.success)
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
