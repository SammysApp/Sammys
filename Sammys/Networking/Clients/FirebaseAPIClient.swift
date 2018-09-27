//
//  FirebaseAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase
import FirebaseDatabase
import CodableFirebase

protocol PathStringRepresentable {
    var pathString: String { get }
}

extension RawRepresentable where Self: PathStringRepresentable, RawValue == String {
    var pathString: String {
        return rawValue
    }
}

enum FirebaseAPIError: Error {
    case snapshotDoesntExist
    case noSnapshotValue
    case dataNotCommitted
    case dataNotExpectedValue
}

typealias FirebaseUser = Firebase.User
typealias ObservableSnapshotPromise = Variable<Promise<DataSnapshot>>

enum FirebaseUserState {
    case currentUser(FirebaseUser)
    case noUser
}

struct FirebaseAPIClient {
    private enum EnvironmentPath: String, PathStringRepresentable {
        case develop, live
    }
    
    // MARK: - Codable
    private static var firebaseEncoder: FirebaseEncoder {
        let encoder = FirebaseEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    private static var firebaseDecoder: FirebaseDecoder {
        let decoder = FirebaseDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    static func encode<T: Encodable>(_ value: T) throws -> Any {
        return try firebaseEncoder.encode(value)
    }
    
    static func decode<T: Decodable>(_ snapshot: DataSnapshot) throws -> T {
        guard let value = snapshot.value else { throw FirebaseAPIError.noSnapshotValue }
        return try firebaseDecoder.decode(T.self, from: value)
    }
    
    // MARK: - Database
    static func databaseReference(_ path: [PathStringRepresentable]) -> DatabaseReference {
        let database = Database.database().reference()
        let environmentDatabase = database.child(environment.isLive ? EnvironmentPath.live : EnvironmentPath.develop)
        return path.isEmpty ? environmentDatabase : environmentDatabase.child(path)
    }
    
    static func databaseReference(_ path: PathStringRepresentable...) -> DatabaseReference {
        return databaseReference(path)
    }
    
    static func set<T: Encodable>(_ value: T, at databaseReference: DatabaseReference = databaseReference()) throws {
        databaseReference.setValue(try encode(value))
    }
    
    static func get<T: Decodable>(at databaseReference: DatabaseReference = databaseReference()) -> Promise<T> {
        return observeOnce(at: databaseReference).map(decode)
    }
    
    static func observeOnce(for eventType: DataEventType = .value, at databaseReference: DatabaseReference = databaseReference()) -> Promise<DataSnapshot> {
        return Promise { databaseReference.observeSingleEvent(of: eventType, with: $0.resolve) }
    }
    
    static func observableSnapshot(for eventType: DataEventType = .value, at databaseQuery: DatabaseQuery = databaseReference()) -> ObservableSnapshotPromise {
        let observableSnapshot = ObservableSnapshotPromise()
        databaseQuery.observe(eventType) { snapshot in
            observableSnapshot.value = Promise { $0.resolve(snapshot: snapshot) }
        }
        return observableSnapshot
    }
    
    static func attemptTransaction<T>(_ transaction: @escaping (T?) -> T, at databaseReference: DatabaseReference = databaseReference()) -> Promise<T> {
        return Promise<T> {
            databaseReference.runTransactionBlock({ currentData in
                currentData.value = transaction(currentData.value as? T)
                return .success(withValue: currentData)
            }, andCompletionBlock: $0.resolveTransaction)
        }
    }
    
    static func incrementCounter(at databaseReference: DatabaseReference = databaseReference()) -> Promise<Int> {
        return attemptTransaction({ $0 == nil ? 1 : $0! + 1 }, at: databaseReference)
    }
    
    // MARK: - Auth
    private static var defaultAuth: Auth { return Auth.auth() }
    
    static func observableUserState() -> Variable<FirebaseUserState> {
        let observableUserState = Variable<FirebaseUserState>()
        Auth.auth().addStateDidChangeListener { auth, user in
            observableUserState.value = user == nil ? .noUser : .currentUser(user!)
        }
        return observableUserState
    }
    
    static func createUser(withEmail email: String, password: String) -> Promise<FirebaseUser> {
        return Promise { defaultAuth.createUser(withEmail: email, password: password, completion: $0.resolve) }
    }
    
    static func signIn(withEmail email: String, password: String) -> Promise<FirebaseUser> {
        return Promise { defaultAuth.signIn(withEmail: email, password: password, completion: $0.resolve) }
    }
    
    static func signIn(with credential: AuthCredential) -> Promise<FirebaseUser> {
        return Promise { defaultAuth.signInAndRetrieveData(with: credential, completion: $0.resolve) }
    }
    
    static func reauthenticate(_ user: FirebaseUser, with userData: UserData, using providerType: AuthProvider.Type = EmailAuthProvider.self) -> Promise<FirebaseUser> {
        return Promise { user.reauthenticateAndRetrieveData(with: providerType.credential(with: userData), completion: $0.resolve) }
    }
    
    static func update(_ user: FirebaseUser, with fields: UserUpdateFields) -> Promise<FirebaseUser> {
        return Promise { resolver in
            let request = user.createProfileChangeRequest()
            request.displayName = fields.name
            request.commitChanges { resolver.resolve(value: user, error: $0) }
        }
    }
    
    static func update(_ user: FirebaseUser, withEmail email: String) -> Promise<FirebaseUser> {
        return Promise { resolver in user.updateEmail(to: email) { resolver.resolve(user, $0) } }
    }
    
    static func update(_ user: FirebaseUser, withPassword password: String) -> Promise<FirebaseUser> {
        return Promise { resolver in user.updatePassword(to: password) { resolver.resolve(user, $0) } }
    }
    
    static func link(_ providerType: AuthProvider.Type, to user: FirebaseUser, with userData: UserData) -> Promise<FirebaseUser> {
        return Promise { user.linkAndRetrieveData(with: providerType.credential(with: userData), completion: $0.resolve) }
    }
    
    static func signOut() throws {
        try defaultAuth.signOut()
    }
}

struct UserUpdateFields {
    let name: String?
}

// MARK: - AuthProvider
protocol AuthProvider {
    static func credential(with userData: UserData) -> AuthCredential
}

protocol UserData {}

struct EmailUserData: UserData {
    let email: String
    let password: String
}

struct FacebookUserData: UserData {
    let accessToken: String
}

extension EmailAuthProvider: AuthProvider {
    static func credential(with userData: UserData) -> AuthCredential {
        guard let userData = userData as? EmailUserData else { fatalError() }
        return credential(withEmail: userData.email, password: userData.password)
    }
}

extension FacebookAuthProvider: AuthProvider {
    static func credential(with userData: UserData) -> AuthCredential {
        guard let userData = userData as? FacebookUserData else { fatalError() }
        return credential(withAccessToken: userData.accessToken)
    }
}

// MARK: - Resolver
private extension Resolver {
    func resolve(value: T, error: Error?) {
        if let error = error { reject(error) }
        else { fulfill(value) }
    }
    
    func resolveTransaction(error: Error?, didCommit: Bool, snapshot: DataSnapshot?) {
        if let error = error { reject(error) }
        else if !didCommit { reject(FirebaseAPIError.dataNotCommitted) }
        else if let newValue = snapshot?.value as? T { fulfill(newValue) }
        else { reject(FirebaseAPIError.dataNotExpectedValue) }
    }
}

private extension Resolver where T == DataSnapshot {
    func resolve(snapshot: DataSnapshot) {
        if snapshot.exists() { fulfill(snapshot) }
        else { reject(FirebaseAPIError.snapshotDoesntExist) }
    }
}

private extension Resolver where T == FirebaseUser {
    func resolve(result: AuthDataResult?, error: Error?) {
        if let error = error { reject(error) }
        else if let user = result?.user { fulfill(user) }
    }
}

extension DatabaseReference {
    func child(_ path: [PathStringRepresentable]) -> DatabaseReference {
        guard let firstPath = path.first else { fatalError() }
        var finalChild = child(firstPath.pathString)
        path.dropFirst().forEach { finalChild = finalChild.child($0.pathString) }
        return finalChild
    }
    
    func child(_ path: PathStringRepresentable...) -> DatabaseReference {
        return child(path)
    }
}

extension DatabaseQuery {
    func queryOrdered(byChild path: [PathStringRepresentable]) -> DatabaseQuery {
        guard let firstPath = path.first else { fatalError() }
        var pathString = firstPath.pathString
        path.dropFirst().forEach { pathString += "/\($0)" }
        return queryOrdered(byChild: pathString)
    }
    
    func queryOrdered(byChild path: PathStringRepresentable...) -> DatabaseQuery {
        return queryOrdered(byChild: path)
    }
}

extension DataSnapshot {
    var nextChildSnapshot: DataSnapshot? {
        return children.nextObject() as? DataSnapshot
    }
    
    var allChildrenSnapshots: [DataSnapshot]? {
        return children.allObjects as? [DataSnapshot]
    }
    
    func childSnapshot(for path: PathStringRepresentable) -> DataSnapshot? {
        return childSnapshot(forPath: path.pathString)
    }
}
