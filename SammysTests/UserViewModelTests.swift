//
//  UserViewModelTests.swift
//  SammysTests
//
//  Created by Natanel Niazoff on 3/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import XCTest
@testable import Sammys
import PromiseKit

class UserViewModelTests: XCTestCase {
    func testLogOut() {
        let viewModel = UserViewModel(keyValueStore: MockLogOutKeyValueStore(), userAuthManager: MockLogOutUserAuthManager())
        do { try viewModel.logOut() } catch { XCTFail(error.localizedDescription) }
    }
}

// MARK: - Log Out Mocks
struct MockLogOutKeyValueStore: KeyValueStore {
    func set<T>(_ value: T?, forKey key: KeyValueStoreKey) {
        XCTAssertEqual(key.rawValue, KeyValueStoreKeys.currentOutstandingOrderID.rawValue)
        XCTAssertNil(value)
    }
    
    func value<T>(of type: T.Type, forKey key: KeyValueStoreKey) -> T? { return nil }
}

struct MockLogOutUserAuthManager: UserAuthManager {
    var isUserSignedIn: Bool { return true }
    func createAndSignInUser(email: String, password: String) -> Promise<Void> { return Promise { $0.fulfill(()) } }
    func signInUser(email: String, password: String) -> Promise<Void> { return Promise { $0.fulfill(()) } }
    func getCurrentUserIDToken() -> Promise<JWT> { return Promise { $0.fulfill(JWT()) } }
    
    func signOutCurrentUser() throws { XCTAssert(true) }
}
