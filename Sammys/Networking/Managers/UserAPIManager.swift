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

struct UserAPIManager: FirebaseAPIManager {
    enum Path: String, PathStringRepresentable {
        case users
        case customerID
    }
    
    // MARK: - User
    private func databaseReference(for user: User) -> DatabaseReference {
		return databaseReference(.users).child(user.id)
    }
    
    private func databaseReference(for firebaseUser: FirebaseUser) -> DatabaseReference {
        return databaseReference(.users).child(firebaseUser.uid)
    }
	
	private func user(for firebaseUser: FirebaseUser) -> Promise<User> {
		return Client.get(at: databaseReference(for: firebaseUser))
	}
    
	private func makeUser(fromFirebaseUser user: FirebaseUser, providers: [UserProvider] = [], payment: User.Payment) throws -> User {
        guard let email = user.email, let name = user.displayName else { throw UserAPIError.notEnoughDetails }
		return User(id: user.uid, email: email, name: name, providers: providers, payment: payment)
    }
	
	func currentUserState() -> Promise<UserState> {
		guard let firebaseUser = Client.currentUser else { return Promise { $0.fulfill(.noUser) } }
		return user(for: firebaseUser).map { .currentUser($0) }
	}
    
	func createUser(withName name: String, email: String, password: String, payment: User.Payment) -> Promise<User> {
        return Client.createUser(withEmail: email, password: password)
		.then { self.update($0, withName: name) }
		.map { try self.makeUser(fromFirebaseUser: $0, providers: [.email], payment: payment) }
		.get { try Client.set($0, at: self.databaseReference(for: $0)) }
    }
    
	func signIn(withEmail email: String, password: String) -> Promise<User> {
        return Client.signIn(withEmail: email, password: password).then(user)
    }
    
	func signIn(withFacebookAccessToken accessToken: String) -> Promise<User> {
        return Client.signIn(with: FacebookAuthProvider.credential(with: FacebookUserData(accessToken: accessToken))).then(user)
    }
    
	func reauthenticate(_ user: FirebaseUser, withEmail email: String, password: String) -> Promise<User> {
        return Client.reauthenticate(user, with: EmailUserData(email: email, password: password)).then(self.user)
    }
    
	func reauthenticate(_ user: FirebaseUser, withFacebookAccessToken accessToken: String) -> Promise<User> {
        return Client.reauthenticate(user, with: FacebookUserData(accessToken: accessToken), using: FacebookAuthProvider.self).then(self.user)
    }
    
	func update(_ user: FirebaseUser, withName name: String) -> Promise<FirebaseUser> {
        return Client.update(user, with: UserUpdateFields(name: name))
    }
    
	func update(_ user: FirebaseUser, withEmail email: String) -> Promise<FirebaseUser> {
        return Client.update(user, withEmail: email)
    }
    
	func update(_ user: FirebaseUser, withPassword password: String) -> Promise<FirebaseUser> {
        return Client.update(user, withPassword: password)
    }
    
	func linkEmailAuthProvider(to user: FirebaseUser, withPassword password: String) -> Promise<FirebaseUser> {
        guard let email = user.email else { return Promise(error: UserAPIError.notEnoughDetails) }
        return Client.link(EmailAuthProvider.self, to: user, with: EmailUserData(email: email, password: password))
    }
    
	func signOut() throws {
        try Client.signOut()
    }
    
    // MARK: - Payment
	func set(customerID: String, for user: User) throws {
        try Client.set(customerID, at: databaseReference(for: user).child(Path.customerID))
    }
    
	func getCustomerID(for user: User) -> Promise<String> {
        return Client.get(at: databaseReference(for: user).child(Path.customerID))
    }
}
