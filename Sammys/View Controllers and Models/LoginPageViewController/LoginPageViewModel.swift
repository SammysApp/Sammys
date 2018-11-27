//
//  LoginPageViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum LoginPage: String {
    case login, name, email, password
	
	static var firstSignUpPage: LoginPage { return .name }
	static var lastSignUpPage: LoginPage { return .password }
}

extension LoginPage: Hashable {}
extension LoginPage: CaseIterable {}

enum LoginPageViewModelError: Error { case missingSignUpFields }

class LoginPageViewModel {
	private let userAPIManager = UserAPIManager()
	private let stripeAPIManager = StripeAPIManager()
	
	private var defaultPage = LoginPage.login
	lazy var currentPage = defaultPage
	var isAtLastSignUpPage: Bool { get { return currentPage == .lastSignUpPage } }
	
	var signUpFields = [LoginPage : String]()
	
	private var currentPageIndex: Int? {
		return LoginPage.allCases.firstIndex(of: currentPage)
	}
	
	func incrementOrLoopCurrentPage() {
		guard let currentPageIndex = currentPageIndex,
			let incrementedPage = LoginPage.allCases[safe: currentPageIndex + 1]
			else { currentPage = defaultPage; return }
		currentPage = incrementedPage
	}
	
	func decrementCurrentPage() {
		guard let currentPageIndex = currentPageIndex,
			let decrementedPage = LoginPage.allCases[safe: currentPageIndex - 1]
			else { return }
		currentPage = decrementedPage
	}
	
	func signUp() -> Promise<User> {
		guard let name = signUpFields[.name],
			let email = signUpFields[.email],
			let password = signUpFields[.password]
			else { return Promise(error: LoginPageViewModelError.missingSignUpFields) }
		return stripeAPIManager.createCustomer(email: email)
			.then { self.userAPIManager.createUser(withName: name, email: email, password: password, payment: User.Payment(id: $0.id)) }
	}
}
