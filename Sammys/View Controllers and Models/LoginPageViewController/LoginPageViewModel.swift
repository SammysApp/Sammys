//
//  LoginPageViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum LoginPageIndex: Int {
    case login, name, email, password
}

extension LoginPageIndex: CaseIterable {}

class LoginPageViewModel {
	private var defaultPageIndex = LoginPageIndex.login
	private(set) lazy var currentPageIndex = defaultPageIndex
	
	func incrementOrLoopCurrentPageIndex() {
		guard let incrementedPageIndex = LoginPageIndex(rawValue: currentPageIndex.rawValue + 1) else { currentPageIndex = defaultPageIndex; return }
		currentPageIndex = incrementedPageIndex
	}
	
	func decrementCurrentPageIndex() {
		guard let decrementedPageIndex = LoginPageIndex(rawValue: currentPageIndex.rawValue - 1) else { return }
		currentPageIndex = decrementedPageIndex
	}
}
