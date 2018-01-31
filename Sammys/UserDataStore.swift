//
//  UserDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class UserDataStore {
    static let shared = UserDataStore()
    var user: User?
    
    // id to identify as observer
    var id = UUID().uuidString
    // handles an update to current user
    lazy var handleUserStateChange: ((UserState) -> Void) = { userState in
        switch userState {
        case .noUser:
            self.user = nil
        case .currentUser(let user):
            self.user = user
        }
    }
    
    private init() {}
    
    func setAsUserAPIObsever() {
        UserAPIClient.addObserver(self)
    }
}

extension UserDataStore: UserAPIObserver {}
