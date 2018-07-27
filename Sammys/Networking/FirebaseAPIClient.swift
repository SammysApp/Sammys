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

enum EnvironmentPath: String, PathStringRepresentable {
    case develop, live
}

enum FirebaseError: Error {
    case snapshotDoesntExist
    case noSnapshotValue
    case dataNotCommitted
    case dataNotExpectedValue
}

struct FirebaseAPIClient {
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
    
    static func databaseReference(_ path: PathStringRepresentable...) -> DatabaseReference {
        return databaseReference(path)
    }
    
    static func databaseReference(_ path: [PathStringRepresentable]) -> DatabaseReference {
        let database = Database.database().reference()
        let environmentDatabase = database.child(environment.isLive ? EnvironmentPath.live : EnvironmentPath.develop)
        return path.isEmpty ? environmentDatabase : environmentDatabase.child(path)
    }
    
    static func encode<T: Encodable>(_ value: T) throws -> Any {
        return try firebaseEncoder.encode(value)
    }
    
    static func decode<T: Decodable>(_ snapshot: DataSnapshot) throws -> T {
        guard let value = snapshot.value else { throw FirebaseError.noSnapshotValue }
        return try firebaseDecoder.decode(T.self, from: value)
    }
    
    static func set<T: Encodable>(_ value: T, at databaseReference: DatabaseReference = databaseReference()) throws {
        databaseReference.setValue(try encode(value))
    }
    
    typealias ObservableSnapshot = Variable<Promise<DataSnapshot>>
    static func observableSnapshot(for event: DataEventType = .value, at databaseQuery: DatabaseQuery = databaseReference()) -> ObservableSnapshot {
        let observableSnapshot = ObservableSnapshot()
        databaseQuery.observe(event) { snapshot in
            observableSnapshot.value = Promise { resolver in
                resolveSnapshot(resolver: resolver, snapshot: snapshot)
            }
        }
        return observableSnapshot
    }
    
    private static func resolveSnapshot(resolver: Resolver<DataSnapshot>, snapshot: DataSnapshot) {
        guard snapshot.exists() else { resolver.reject(FirebaseError.snapshotDoesntExist); return }
        resolver.fulfill(snapshot)
    }
    
    static func attemptTransaction<T>(_ transaction: @escaping (T?) -> T, at databaseReference: DatabaseReference = databaseReference()) -> Promise<T> {
        return Promise<T> { resolver in
            databaseReference.runTransactionBlock({ currentData in
                currentData.value = transaction(currentData.value as? T)
                return .success(withValue: currentData)
            }) { error, didCommit, snapshot in
                if let error = error { resolver.reject(error); return }
                guard didCommit else { resolver.reject(FirebaseError.dataNotCommitted); return }
                guard let newValue = snapshot?.value as? T else { resolver.reject(FirebaseError.dataNotExpectedValue); return }
                resolver.fulfill(newValue)
            }
        }
    }
    
    static func incrementCounter(at databaseReference: DatabaseReference = databaseReference()) -> Promise<Int> {
        return attemptTransaction({ $0 == nil ? 1 : $0! + 1 }, at: databaseReference)
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
