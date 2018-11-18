//
//  LoginPageViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum LoginPage: String {
    case login, name, email, password
	
	static var firstSignUpPage: LoginPage { return .name }
}

extension LoginPage: CaseIterable {}

class LoginPageViewModel {
	private var defaultPage = LoginPage.login
	lazy var currentPage = defaultPage
	
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
}
