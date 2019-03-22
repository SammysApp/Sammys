//
//  FirebaseAuth+UserAuthManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

extension Auth: UserAuthManager {
    func createAndSignInUser(email: String, password: String) -> Promise<Void> {
        return Promise { resolver in
            self.createUser(withEmail: email, password: password) { _, error in
                if let error = error { resolver.reject(error) }
                else { resolver.fulfill(()) }
            }
        }
    }
    
    func signInUser(email: String, password: String) -> Promise<Void> {
        return Promise { resolver in
            self.signIn(withEmail: email, password: password) { _, error in
                if let error = error { resolver.reject(error) }
                else { resolver.fulfill(()) }
            }
        }
    }
    
    func getCurrentUserIDToken() -> Promise<JWT> {
        guard let currentUser = self.currentUser else { return Promise(error: UserAuthManagerError.noCurrentUser) }
        return Promise { resolver in
            currentUser.getIDTokenForcingRefresh(true) { jwt, error in
                if let error = error { resolver.reject(error) }
                else if let jwt = jwt { resolver.fulfill(jwt) }
            }
        }
    }
}
