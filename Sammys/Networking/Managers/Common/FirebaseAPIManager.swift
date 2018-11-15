//
//  FirebaseAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseAPIManager {
    associatedtype Path: PathStringRepresentable
}

extension FirebaseAPIManager {
    typealias Client = FirebaseAPIClient
    
	func databaseReference(_ path: Path...) -> DatabaseReference {
		return Client.databaseReference(path)
    }
}
