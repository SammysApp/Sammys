//
//  UserAuthManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

protocol UserAuthManager {
    func createAndSignInUser(email: String, password: String) -> Promise<Void>
    func signInUser(email: String, password: String) -> Promise<Void>
    func getCurrentUserIDToken() -> Promise<JWT>
    func signOutCurrentUser() throws
}

enum UserAuthManagerError: Error {
    case noCurrentUser
}
