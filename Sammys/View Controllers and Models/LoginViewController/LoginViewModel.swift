//
//  LoginViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import PromiseKit

enum LoginMethod { case login, reauthenticate }

struct LoginViewModelParcel {
	let method: LoginMethod
}

struct LoginFields {
	let email: String
	let password: String
}

class LoginViewModel {
	private let parcel: LoginViewModelParcel
	
	private let userAPIManager = UserAPIManager()
	
	init(_ parcel: LoginViewModelParcel) {
		self.parcel = parcel
	}
	
	func login(with fields: LoginFields) -> Promise<User> {
		return userAPIManager.signIn(withEmail: fields.email, password: fields.password)
	}
}
