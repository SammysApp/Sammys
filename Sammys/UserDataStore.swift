//
//  UserDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A singleton type that stores 📦 user 👩🏻 data.
class UserDataStore {
    /// The shared single instance.
    static let shared = UserDataStore()
    
    /// The currently signed in user.
    var user: User?
    
    let id = UUID().uuidString
    
    private init() {}
    
    /// Sets self to be observer of `UserAPIClient` to listen to things like changes in user state.
    func setAsUserAPIObsever() {
        UserAPIClient.addObserver(self)
    }
}

extension UserDataStore: UserAPIObserver {
    var userStateDidChange: ((UserState) -> Void)? {
        return { userState in
            switch userState {
            case .noUser:
                self.user = nil
            case .currentUser(let user):
                self.user = user
            }
        }
    }
    
    var favoritesValueDidChange: (([FavoriteGroup]) -> Void)? {
        return { favorites in
            self.user?.favorites = favorites
        }
    }
}
