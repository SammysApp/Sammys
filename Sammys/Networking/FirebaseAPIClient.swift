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

enum FirebaseError: Error {
    case snapshotDoesntExist
    case noSnapshotValue
}

private var firebaseEncoder: FirebaseEncoder {
    let encoder = FirebaseEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}

private var firebaseDecoder: FirebaseDecoder {
    let decoder = FirebaseDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}

func decode<T: Decodable>(_ snapshot: DataSnapshot) throws -> T {
    guard let value = snapshot.value else { throw FirebaseError.noSnapshotValue }
    return try firebaseDecoder.decode(T.self, from: value)
}

typealias ObservableSnapshot = Variable<Promise<DataSnapshot>>
func observableSnapshot(for event: DataEventType = .value, at databaseQuery: DatabaseQuery = Database.database().reference().child(Path.develop, Path.orders)) -> ObservableSnapshot {
    let observableSnapshot = ObservableSnapshot()
    databaseQuery.observe(event) { snapshot in
        observableSnapshot.value = Promise { resolver in
            resolveSnapshot(resolver: resolver, snapshot: snapshot)
        }
    }
    return observableSnapshot
}

private func resolveSnapshot(resolver: Resolver<DataSnapshot>, snapshot: DataSnapshot) {
    guard snapshot.exists() else { resolver.reject(FirebaseError.snapshotDoesntExist); return }
    resolver.fulfill(snapshot)
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
