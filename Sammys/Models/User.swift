//
//  User.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum UserState { case noUser, currentUser(User) }

enum UserProvider: String { case email, facebook }

extension UserProvider: Codable {}

class User: Codable {
    var id: String
    var email: String
    var name: String
    var providers: [UserProvider]
	var payment: Payment
    
	init(id: String, email: String, name: String, providers: [UserProvider] = [], payment: Payment) {
        self.id = id
        self.email = email
        self.name = name
        self.providers = providers
		self.payment = payment
    }
	
	struct Payment: Codable {
		var ids: [PaymentService : String]
	}
}
