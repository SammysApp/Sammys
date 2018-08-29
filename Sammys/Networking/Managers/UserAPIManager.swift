//
//  UserAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase

enum UserAPIError: Error {
    case notEnoughDetails
}

/// A client to make user calls to the user 👩🏻 API 🏭.
struct UserAPIManager: FirebaseAPIManager {
    enum Path: String, PathStringRepresentable {
        case users
        case favorites
        case customerID
    }
    
    // MARK: - User 💁🏻‍♀️
    private static func databaseReference(for user: User) -> DatabaseReference {
        return databaseReference(.users).child(user.id)
    }
    
    private static func databaseReference(for firebaseUser: FirebaseUser) -> DatabaseReference {
        return databaseReference(.users).child(firebaseUser.uid)
    }
    
    private static func createUser(fromFirebaseUser user: FirebaseUser, providers: [UserProvider] = []) throws -> User {
        guard let email = user.email, let name = user.displayName else { throw UserAPIError.notEnoughDetails }
        return User(id: user.uid, email: email, name: name, providers: providers)
    }
    
    /// Creates a `User` configured with an email provider and adds them to the database.
    static func createUser(withName name: String, email: String, password: String) -> Promise<User> {
        return Client.createUser(withEmail: email, password: password)
        .then { update($0, withName: name) }
        .map { try createUser(fromFirebaseUser: $0, providers: [.email]) }
        .get { try Client.set($0, at: databaseReference(for: $0)) }
    }
    
    /// Returns the `User` from the database upon signing in successfully.
    static func signIn(withEmail email: String, password: String) -> Promise<User> {
        return Client.signIn(withEmail: email, password: password)
        .then { Client.get(at: databaseReference(for: $0)) }
    }
    
    static func signIn(withFacebookAccessToken accessToken: String) -> Promise<User> {
        return Client.signIn(with: FacebookAuthProvider.credential(with: FacebookUserData(accessToken: accessToken)))
        .then { Client.get(at: databaseReference(for: $0)) }
    }
    
    static func reauthenticate(_ user: FirebaseUser, withEmail email: String, password: String) -> Promise<User> {
        return Client.reauthenticate(user, with: EmailUserData(email: email, password: password))
        .then { Client.get(at: databaseReference(for: $0)) }
    }
    
    static func reauthenticate(_ user: FirebaseUser, withFacebookAccessToken accessToken: String) -> Promise<User> {
        return Client.reauthenticate(user, with: FacebookUserData(accessToken: accessToken), using: FacebookAuthProvider.self)
        .then { Client.get(at: databaseReference(for: $0)) }
    }
    
    static func update(_ user: FirebaseUser, withName name: String) -> Promise<FirebaseUser> {
        return Client.update(user, with: UserUpdateFields(name: name))
    }
    
    static func update(_ user: FirebaseUser, withEmail email: String) -> Promise<FirebaseUser> {
        return Client.update(user, withEmail: email)
    }
    
    static func update(_ user: FirebaseUser, withPassword password: String) -> Promise<FirebaseUser> {
        return Client.update(user, withPassword: password)
    }
    
    static func linkEmailAuthProvider(to user: FirebaseUser, withPassword password: String) -> Promise<FirebaseUser> {
        guard let email = user.email else { return Promise(error: UserAPIError.notEnoughDetails) }
        return Client.link(EmailAuthProvider.self, to: user, with: EmailUserData(email: email, password: password))
    }
    
    static func signOut() throws {
        try Client.signOut()
    }
    
    // MARK: - Payment 💰
    static func set(customerID: String, for user: User) throws {
        try Client.set(customerID, at: databaseReference(for: user).child(Path.customerID))
    }
    
    static func getCustomerID(for user: User) -> Promise<String> {
        return Client.get(at: databaseReference(for: user).child(Path.customerID))
    }
}
