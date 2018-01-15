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
    
    private init() {}
}
