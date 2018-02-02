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
    var userStateDidChange: ((UserState) -> Void)? { get }
    var favoritesValueDidChange: (([Salad]) -> Void)? { get }
}

extension UserAPIObserver {
//    var userStateDidChange: ((UserState) -> Void)? {
//        return nil
//    }
//
//    var favoritesValueDidChange: (([Salad]) -> Void)? {
//        return nil
//    }
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
                observers.forEach { $0.userStateDidChange?(.noUser) }
            }
        }
    }
    
//    static func startFavoritesValueChangeObserver() {
//        database.observe(.value) { (snapshot) in
//            if let jsonString = snapshot.value as? String, let jsonData = jsonString.data(using: .utf8) {
//                do {
//                    let favorites = try JSONDecoder().decode([Salad].self, from: jsonData)
//                    observers.forEach { $0.favoritesValueDidChange?(favorites) }
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
    
    static func setupCurrentUser(_ user: FirebaseUser) {
        guard let email = user.email, let name = user.displayName
            else { return }
        let currentUser = User(id: user.uid, email: email, name: name)
        observers.forEach { $0.userStateDidChange?(.currentUser(currentUser)) }
    }
    
    static func createUser(withName name: String, email: String, password: String, completionHandler: ((APIResult) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
            } else if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if let error = error {
                        print(error)
                    } else {
                        setupCurrentUser(user)
                        completionHandler?(.success)
                    }
                }
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
    
    static func fetchFavorites(for user: User, completed: (([Salad]) -> Void)? = nil) {
        database.child("users").child(user.id).child("favorites").observeSingleEvent(of: .value) { (snapshot) in
            var favorites = [Salad]()
            for childSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                if let jsonString = childSnapshot.value as? String, let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let favorite = try JSONDecoder().decode(Salad.self, from: jsonData)
                        favorites.append(favorite)
                    } catch {
                        print(error)
                    }
                }
            }
            completed?(favorites)
        }
    }
    
    static func add(_ favorite: Salad, to user: User) {
        do {
            let jsonData = try JSONEncoder().encode(favorite)
            let jsonString = String(data: jsonData, encoding: .utf8)
            database.child("users").child(user.id).child("favorites").child(favorite.id).setValue(jsonString)
        } catch {
            
        }
    }
    
    static func set(_ customerID: String, for user: User) {
        database.child("users").child(user.id).child("customerID").setValue(customerID)
    }
}
